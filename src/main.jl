using DataStructures, LinearAlgebra, Statistics, UnPack, Functors, Zygote, ChainRulesCore, CUDA, ArrayPadding
using Functors: functor
using Zygote: Buffer

include("ops.jl")
include("zero.jl")

include("map/init.jl")
include("map/iters.jl")
include("map/ops.jl")
include("map/queries.jl")
include("map/restruct.jl")

include("vecfields/ops.jl")
include("vecfields/del.jl")

include("string.jl")
include("float.jl")
include("misc.jl")
include("interp.jl")
include("sampling.jl")
include("symmetric.jl")

# using Pkg
# pkg"dev C:\Users\pxshe\OneDrive\Desktop\ArrayPadding.jl;up"
