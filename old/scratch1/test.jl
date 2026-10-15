using Meshes, Zygote

function sample(geom::Geometry{Dim,T}, method::RegularSampling) where {Dim,T}
    V = T <: AbstractFloat ? T : Float64
    D = paramdim(geom)
    sz = Meshes.fitdims(method.sizes, D)
    δₛ = Meshes.firstoffset(geom)
    δₑ = Meshes.lastoffset(geom)
    tₛ = ntuple(i -> V(0 + δₛ[i](sz[i])), D)
    tₑ = ntuple(i -> V(1 - δₑ[i](sz[i])), D)
    rs = (range(tₛ[i], stop=tₑ[i], length=sz[i]) for i in 1:D)
    iᵣ = (geom(uv...) for uv in Iterators.product(rs...))
    iₚ = (p for p in Meshes.extrapoints(geom))
    Iterators.flatmap(identity, (iᵣ, iₚ))
end
f = r -> sum(coordinates((sample(Sphere((0, 0, 0), r), RegularSampling(360, 180))|>collect)[1]))

gradient(f, 1)