module ClearswiApp

using ArgParse
using MriResearchTools
using CLEARSWI

include("argparse.jl")
include("caller.jl")

function julia_main()::Cint
    try
        clearswi_main(ARGS)
    catch
        Base.invokelatest(Base.display_error, Base.catch_stack())
        return 1
    end
    return 0
end

export clearswi_main

end
