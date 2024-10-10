using DataStructures, LinearAlgebra, Statistics, UnPack, Functors, FFTW
using Functors: functor
using Zygote, ChainRulesCore
using ArrayPadding
using Zygote: Buffer
# using ArrayPadding:

include("ad.jl")
include("ops.jl")

include("map/init.jl")
include("map/iters.jl")
include("map/ops.jl")
include("map/queries.jl")
include("map/restruct.jl")

include("string.jl")
include("vf.jl")
include("float.jl")
include("misc.jl")
include("del.jl")
include("nan.jl")
include("interp.jl")
include("sampling.jl")
include("matmul.jl")
include("symmetric.jl")
# a = [2, 3, 4]
# a[1.5]