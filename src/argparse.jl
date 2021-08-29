function getargs(args::AbstractVector)
    if isempty(args)
        args = ["--help"]
    end
    s = ArgParseSettings(
        exc_handler=exception_handler,
        add_version=true,
        version="v1.0.0",
        )
    @add_arg_table! s begin
        "--magnitude", "-m"
            help = "The magnitude image (single or multi-echo)"
        "--phase", "-p"
            help = "The phase image (single or multi-echo)"
        "--output", "-o"
            help = "The output path or filename"
            default = "clearswi.nii"
        "--echo-times", "-t"
            help = """The echo times are required for multi-echo datasets 
                specified in array or range syntax (eg. "[1.5,3.0]" or 
                "3.5:3.5:14")."""
            nargs = '+'
        "--mag-combine"
            help = """SNR | average | echo <n> | SE <te>.
            Magnitude combination algorithm. echo <n> selects a specific echo;
            SE <te> simulates a single echo scan of the given echo time.
            """
            default = ["SNR"]
            nargs = '+'
        "--mag-sensitivity-correction"
            help = """ <filename> | on | off.
            Use the CLEAR-SWI sensitivity correction. Alternatively, a
            sensitivity map can be read from a file"""
            default = "on"
        "--mag-deactivate-softplus-scaling"
            help = "Deactivate softplus scaling of the magnitude"
            action = :store_strue
        "--unwrapping-algorithm"
            help = """laplacian | romeo | laplacianslice"""
            default = "laplacian"
        "--filter-size"
            help = """Size for the high-pass phase filter in voxels. Can be
            given as <x> <y> <z> or in array syntax (e.g. [2.2 3.1, 0], which
            is effectively a 2D filter)."""
            nargs = +
            default = [4,4,0]
        "--phase-scaling-type"
            help = """"""

    end
    return parse_args(args, s)
end

function exception_handler(settings::ArgParseSettings, err, err_code::Int=1)
    if err == ArgParseError("too many arguments")
        println(stderr,
            """wrong argument formatting!"""
        )
    end
    ArgParse.default_handler(settings, err, err_code)
end

function getechoes(settings, neco)
    echoes = eval(Meta.parse(join(settings["unwrap-echoes"], " ")))
    if echoes isa Int
        echoes = [echoes]
    elseif echoes isa Matrix
        echoes = echoes[:]
    end
    echoes = (1:neco)[echoes] # expands ":"
    if (length(echoes) == 1) echoes = echoes[1] end
    return echoes
end

function getTEs(settings, neco, echoes)
    if isempty(settings["echo-times"])
        if neco == 1 || length(echoes) == 1
            return 1
        else
            error("multi-echo data is used, but no echo times are given. Please specify the echo times using the -t option.")
        end
    end
    TEs = if settings["echo-times"][1] == "epi"
        ones(neco) .* if length(settings["echo-times"]) > 1; parse(Float64, settings["echo-times"][2]) else 1 end
    else
        eval(Meta.parse(join(settings["echo-times"], " ")))
    end
    if TEs isa Matrix
        TEs = TEs[:]
    end
    if length(TEs) == neco
        TEs = TEs[echoes]
    end
    return TEs
end

function parseweights(settings)
    if isfile(settings["weights"]) && splitext(settings["weights"])[2] != ""
        return UInt8.(niread(settings["weights"]))
    else
        try
            reform = "Bool[$(join(collect(settings["weights"]), ','))]"
            flags = falses(6)
            flags[1:4] = eval(Meta.parse(reform))
            return flags
        catch
            return Symbol(settings["weights"])
        end
    end
end

function saveconfiguration(writedir, settings, args)
    writedir = abspath(writedir)
    open(joinpath(writedir, "settings_romeo.txt"), "w") do io
        for (fname, val) in settings
            if !(typeof(val) <: AbstractArray)
                println(io, "$fname: " * string(val))
            end
        end
        println(io, """Arguments: $(join(args, " "))""")
    end
end
