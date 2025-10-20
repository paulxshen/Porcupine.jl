Base.length(::Symbol) = 1
# Base.iterate(s::Symbol, i=1) = i > 1 ? nothing : (s, i + 1)
Base.getindex(s::Symbol, i) = Symbol(String(s)[i])
Base.convert(::Type{Symbol}, x::String) = Symbol(x)
Base.convert(::Type{String}, x::Symbol) = string(x)


Base.startswith(s, x) = startswith(string(s), string(x))

function togreek(x::T) where {T}
    s = string(x)
    s = replace(s,
        "alpha" => "α",
        "beta" => "β",
        "gamma" => "γ",
        "delta" => "δ",
        "epsilon" => "ϵ",
        "zeta" => "ζ",
        "eta" => "η",
        "theta" => "θ",
        "iota" => "ι",
        "kappa" => "κ",
        "lambda" => "λ",
        "mu" => "μ",
        "nu" => "ν",
        "xi" => "ξ",
        "omicron" => "ο",
        "pi" => "π",
        "rho" => "ρ",
        "sigma" => "σ",
        "tau" => "τ",
        "upsilon" => "υ",
        "phi" => "φ",
        "chi" => "χ",
        "psi" => "ψ",
        "omega" => "ω",
    ) |> T
end

function fromgreek(x::T) where {T}
    s = string(x)
    s = replace(s,
        "α" => "alpha",
        "β" => "beta",
        "γ" => "gamma",
        "δ" => "delta",
        "ϵ" => "epsilon",
        "ζ" => "zeta",
        "η" => "eta",
        "θ" => "theta",
        "ι" => "iota",
        "κ" => "kappa",
        "λ" => "lambda",
        "μ" => "mu",
        "ν" => "nu",
        "ξ" => "xi",
        "ο" => "omicron",
        "π" => "pi",
        "ρ" => "rho",
        "σ" => "sigma",
        "τ" => "tau",
        "υ" => "upsilon",
        "φ" => "phi",
        "χ" => "chi",
        "ψ" => "psi",
        "ω" => "omega",
    ) |> T
end