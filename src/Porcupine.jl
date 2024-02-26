module Porcupine
using UnPack, LinearAlgebra, Zygote, ArrayPadding
using Zygote: Buffer
include("del.jl")
export Del, StaggeredDel, CenteredDel#, Lap, Op, Gauss
end # module FDMTK
