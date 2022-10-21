using ClearswiApp
using Test

@testset "ClearswiApp.jl" begin
    
niread = ClearswiApp.niread
savenii = ClearswiApp.savenii

p = joinpath("data", "small")
phasefile_me = joinpath(p, "Phase.nii")
phasefile_me_nan = joinpath(p, "phase_with_nan.nii")
magfile_me = joinpath(p, "Mag.nii")
tmpdir = mktempdir()
phasefile_1eco = joinpath(tmpdir, "Phase.nii")
magfile_1eco = joinpath(tmpdir, "Mag.nii")
phasefile_1arreco = joinpath(tmpdir, "Phase.nii")
magfile_1arreco = joinpath(tmpdir, "Mag.nii")
magfile_me_nan_size = joinpath(tmpdir, "mag_nan_size.nii")
maskfile = joinpath(tmpdir, "Mask.nii")
savenii(niread(magfile_me)[:,:,:,1] |> I -> I .> ClearswiApp.MriResearchTools.median(I), maskfile)
savenii(niread(phasefile_me)[:,:,:,1], phasefile_1eco)
savenii(niread(magfile_me)[:,:,:,1], magfile_1eco)
savenii(niread(phasefile_me)[:,:,:,[1]], phasefile_1arreco)
savenii(niread(magfile_me)[:,:,:,[1]], magfile_1arreco)
savenii(ones(size(niread(phasefile_me_nan))), magfile_me_nan_size)

function test_clearswi(args)
    folder = tempname()
    args = [args..., "-o", folder]
    try
        msg = clearswi_main(args)
        @test msg == 0
        @test isfile(joinpath(folder, "clearswi.nii"))
    catch e
        println(args)
        println(sprint(showerror, e, catch_backtrace()))
        @test "test failed" == "with error" # signal a failed test
    end
end

configurations_se(pf, mf) = configurations_se(["-p", pf, "-m", mf])
configurations_se(pm) = [
    [pm...],
    [pm..., "--qsm"],
    [pm..., "--mag-combine", "SNR"],
    [pm..., "--mag-combine", "average"],
    [pm..., "--mag-combine", "echo", "2"],
    [pm..., "--mag-combine", "SE", "2.4"],
    [pm..., "--mag-sensitivity-correction", "off"],
    [pm..., "--mag-softplus-scaling", "off"],
    [pm..., "--unwrapping-algorithm", "romeo"],
    #[pm..., "--unwrapping-algorithm", "laplacianslice"], # laplacianslice currently unstable
    [pm..., "--filter-size", "[2,2,3]"],
    [pm..., "--phase-scaling-type", "negativetanh"],
    [pm..., "--phase-scaling-type", "positive"],
    [pm..., "--phase-scaling-type", "negative"],
    [pm..., "--phase-scaling-type", "triangular"],
    [pm..., "--phase-scaling-strength", "1"],
    [pm..., "--phase-scaling-strength", "10"],
    [pm..., "-N"],
    [pm..., "--no-phase-rescale"],
    [pm..., "--writesteps", tmpdir],
]
configurations_me(phasefile_me, magfile_me) = configurations_me(["-p", phasefile_me, "-m", magfile_me])
configurations_me(pm) = [
    [pm..., "-e", "1:2", "-t", "[2,4]"], # giving two echo times for two echoes used out of three
    [pm..., "-e", "[1,3]", "-t", "[2,4,6]"], # giving three echo times for two echoes used out of three
    [pm..., "-e", "[1", "3]", "-t", "[2,4,6]"],
    [pm..., "-t", "[2,4,6]"],
    [pm..., "-t", "2:2:6"],
    [pm..., "-t", "[2.1,4.2,6.3]"],
    [pm..., "-t", "[2.1,4.2,6.3]", "--qsm"],
]

files = [(phasefile_1eco, magfile_1eco), (phasefile_1arreco, magfile_1arreco), (phasefile_1eco, magfile_1arreco), (phasefile_1arreco, magfile_1eco)]
for (pf, mf) in files, args in configurations_se(pf, mf)
    test_clearswi(args)
end
for args in configurations_me(phasefile_me, magfile_me)
    test_clearswi(args)
end
for args in configurations_se(["-p", phasefile_me, "-m", magfile_me, "-t", "[2,4,6]"])
    test_clearswi(args)
end


test_clearswi(["-p", phasefile_1eco, "-m", magfile_1eco, "-t", "5"])
#test_clearswi(["-p", phasefile_me_nan, "-m", magfile_me_nan_size, "-t", "[2,4]"])

end


## print version to verify
println()
clearswi_main(["--version"])
#=
## Test error and warning messages
m = "multi-echo data is used, but no echo times are given. Please specify the echo times using the -t option."
@test_throws ErrorException(m) unwrapping_main(["-p", phasefile_me, "-o", tmpdir, "-v"])

m = "masking option '0.8' is undefined (Maybe '-k qualitymask 0.8' was meant?)"
@test_throws ErrorException(m) unwrapping_main(["-p", phasefile_1eco, "-o", tmpdir, "-v", "-k", "0.8"])

m = "masking option 'blub' is undefined"
@test_throws ErrorException(m) unwrapping_main(["-p", phasefile_1eco, "-o", tmpdir, "-v", "-k", "blub"])

m = "Phase offset determination requires all echo times!"
@test_throws ErrorException(m) unwrapping_main(["-p", phasefile_me_5D, "-o", tmpdir, "-v", "-t", "[1,2]", "-e", "[1,2]", "--phase-offset-correction"])

m = "5D phase is given but no coil combination is selected"
@test_throws ErrorException(m) unwrapping_main(["-p", phasefile_me_5D, "-o", tmpdir, "-v", "-t", "[1,2,3]"])

m = "echoes=[1,5]: specified echo out of range! Number of echoes is 3"
@test_throws ErrorException(m) unwrapping_main(["-p", phasefile_me, "-o", tmpdir, "-v", "-t", "[1,2,3]", "-e", "[1,5]"])

m = "echoes=[1,5} wrongly formatted!"
@test_throws ErrorException(m) unwrapping_main(["-p", phasefile_me, "-o", tmpdir, "-v", "-t", "[1,2,3]", "-e", "[1,5}"])

m = "Number of chosen echoes is 2 (3 in .nii data), but 5 TEs were specified!"
@test_throws ErrorException(m) unwrapping_main(["-p", phasefile_me, "-o", tmpdir, "-v", "-t", "[1,2,3,4,5]", "-e", "[1,2]"])

m = "size of magnitude and phase does not match!"
@test_throws ErrorException(m) unwrapping_main(["-p", phasefile_me, "-o", tmpdir, "-v", "-t", "[1,2,3]", "-m", magfile_1eco])

m = "robustmask was chosen but no magnitude is available. No mask is used!"
@test_logs (:warn, m) match_mode=:any unwrapping_main(["-p", phasefile_1eco, "-o", tmpdir])

@test_logs unwrapping_main(["-p", phasefile_1eco, "-o", tmpdir, "-m", magfile_1eco]) # test that no warning appears


end

=#