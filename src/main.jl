using DataStructures, LinearAlgebra, Statistics, UnPack, Functors, ChainRulesCore, ArrayPadding
using Functors: functor

include("ops.jl")
include("dims.jl")
include("zero.jl")

include("map/init.jl")
include("map/iters.jl")
include("map/ops.jl")
include("map/queries.jl")
include("map/restruct.jl")


include("string.jl")
include("float.jl")
include("misc.jl")
include("arrays.jl")
include("sampling.jl")
include("symmetric.jl")
include("gpu.jl")

# using Pkg
# pkg"dev C:\Users\pxshe\OneDrive\Desktop\ArrayPadding.jl;up"
