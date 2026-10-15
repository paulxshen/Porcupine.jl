using DataStructures, LinearAlgebra, Statistics, UnPack, Functors, ChainRulesCore, ArrayPadding, Format, JSON, StaticArrays#, BFloat16s
using Functors: functor
using ArrayPadding: constructor

include("types.jl")
include("ops.jl")
include("dims.jl")
include("zero.jl")
include("numbers.jl")
include(".indexing.jl")

include("map/init.jl")
include("map/iters.jl")
include("map/ops.jl")
include("map/queries.jl")
include("map/restruct.jl")

include("del.jl")
include("grid.jl")

include("string.jl")
include("float.jl")
include("misc.jl")
include("arrays.jl")
include("symmetric.jl")
include("gpu.jl")

# using Pkg
# pkg"dev C:\Users\pxshe\OneDrive\Desktop\ArrayPadding.jl;up"
