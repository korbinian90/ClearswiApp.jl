module ClearswiApp

using ArgParse
using MriResearchTools
using CLEARSWI

include("argparse.jl")
include("caller.jl")

function julia_main(version)::Cint
    try
        clearswi_main(ARGS; version)
    catch
        Base.invokelatest(Base.display_error, Base.catch_stack())
        return 1
    end
    return 0
end

export clearswi_main

end
