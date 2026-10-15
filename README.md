# Porcupine.jl

Julia conveniences for developer happiness, concise code and automatic differentiation (Zygote). Most features are method overloads activated by `using Porcupine`.

- **Arithmetic across containers**: `+ - * /` automatically recurse through nested and mixed numbers, arrays, tuples, NamedTuples and dicts.
- **Recursive maps**: `rmap`, `vmap`, `kmap`, `kvmap`, `leaves`, `flatten`, and `Float32(x)` on nested containers. `cpu`/`gpu` move every array inside a nested structure.
- **Interpolated indexing** `a(i...)` / `getindexf`: multilinear interpolation at real indices, or over unit-step ranges.
  `Float32[1 2; 3 4](1.5f0, 1.5f0) == 2.5f0`
- **Fuzzy map lookup** `d(k)`: tries an exact key, then nested keys (any depth), Symbol↔String, and the i-th value for an integer key.
  `d(:c) == [1.0, 2.0]`, `d("a") == 1.0`, `d(1) == 1.0`
- **`nothing` as zero**: `nothing + 1 == 1`, which avoids some Zygote `nothing`-tangent errors.
- **Array utilities**: `resize` (linear resampling), `crop`, `place!`, `centroids`, `getbbox`, `indexof`.
- **Misc**: `int` (checked rounding), `𝒻` (pretty formatting), `togreek`/`fromgreek`.


## Contributors
Paul Shen, pxshen@alumni.stanford.edu, Luminescent AI
