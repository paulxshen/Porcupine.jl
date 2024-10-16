using DataStructures, LinearAlgebra, Statistics, UnPack, Functors, FFTW, TrackedFloats
using Zygote, ChainRulesCore, CUDA, ArrayPadding
using Functors: functor
using Zygote: Buffer

include("ops.jl")
include("zero.jl")

include("map/init.jl")
include("map/iters.jl")
include("map/ops.jl")
include("map/queries.jl")
include("map/restruct.jl")

include("string.jl")
include("float.jl")
include("misc.jl")
include("del.jl")
include("interp.jl")
include("sampling.jl")
include("matmul.jl")
include("symmetric.jl")
# a = [2, 3, 4]
# a[1.5]