# ClearswiApp [deprecated]
The functionality has moved to [CLEARSWI.jl as an extension](https://github.com/korbinian90/CLEARSWI.jl).

New usage explanation:
https://github.com/korbinian90/CLEARSWI.jl#usage---command-line-via-julia

---------------
[![Build Status](https://github.com/korbinian90/ClearswiApp.jl/workflows/CI/badge.svg)](https://github.com/korbinian90/ClearswiApp.jl/actions)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/korbinian90/ClearswiApp.jl?svg=true)](https://ci.appveyor.com/project/korbinian90/ClearswiApp-jl)
[![Coverage](https://codecov.io/gh/korbinian90/ClearswiApp.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/korbinian90/ClearswiApp.jl)

Easy way to apply CLEARSWI in the command line without Julia programming experience. This repository is a wrapper of [CLEARSWI.jl](https://github.com/korbinian90/CLEARSWI.jl).

Another possibility without requiring a Julia installation is the compiled version under [CLEARSWI](https://github.com/korbinian90/CLEARSWI).

Please cite [CLEAR-SWI NeuroImage](https://doi.org/10.1016/j.neuroimage.2021.118175) if you use it!

## Getting Started

1. Install Julia

   Please install Julia using the binaries from this page https://julialang.org. (Julia 1.5 or newer is required, some package managers install outdated versions)

2. Install ClearswiApp

   Start Julia (Type julia in the command line or start the installed Julia executable)

   Type the following in the Julia REPL:
   ```julia
   julia> ] # Be sure to type the closing bracket via the keyboard
   # Enters the Julia package manager
   (@v1.5) pkg> add https://github.com/korbinian90/CLEARSWI.jl
   (@v1.5) pkg> add https://github.com/korbinian90/ClearswiApp.jl
   # All dependencies are installed automatically
   ```

3. Usage in Julia REPL

   ```julia
   julia> using ClearswiApp
   julia> args = "-p phase.nii -m mag.nii -t [2.1,4.2,6.3] -o /tmp"
   julia> clearswi_main(split(args))
   ```

4. Command line usage

   Copy the file `clearswi.jl` to a convenient location. Open a command line in the calculation folder. An alias for `clearswi` as `julia <path-to-file>/clearswi.jl` might be convenient.
   ```
      $ julia <path-to-file>/clearswi.jl -p phase.nii -m mag.nii -t [2.1,4.2,6.3] -o results
   ```

5. Help

   Calling the Julia script without arguments (or --help) displays all options.
   ```
      $ julia <path-to-file>/clearswi.jl
   ```

## License
This project is licensed under the MIT License - see the [LICENSE](https://github.com/korbinian90/CLEARSWI.jl/blob/master/LICENSE) for details
