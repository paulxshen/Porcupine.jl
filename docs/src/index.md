# Porcupine.jl

Syntactic sugar for Finite difference operators on scalar and vector fields, including derivative, gradient, divergence, curl and exterior derivative in 1d/2d/3d.  Scalar fields are arrays or singleton vector of an array while vector fields are represented as vector of arrays. Arithmetic and linear algebra operations are overloaded over fields to automatically broadcast.

See FDTDEngine.jl `src/maxwell.jl` for example usage

```@docs
Del
Lap
```

## Contributors
Paul Shen, Stanford MS EE, pxshen@alumni.stanford.edu
