# Porcupine.jl

Collection of Julia hacks for optimizing developer happiness and automatic differentiation. Most features are implemented as method overloads which are implicitly activated by importing the package. Features include:
- Allows arithmetic operations (+-*/) between different types including numbers, arrays, tuples, and nested named tuples and dictionaries using recursive broadcasting. 
- Defines new operators:
    - `⊙` for recursively elementwise * instead of matrix multiplication
    - `⊘` for recursively elementwise / instead of matrix division
- Allows arithmetic operations with `nothing` which is treated like zero. Fixes some `Zygote.jl` errors involving `nothing` tangent propagation.
- Linear interpolation of multidimensional arrays via () syntax. Also works on ranges but only if step size is 1.
- "Fuzzy" indexing for named tuples and dictionaries via () syntax. If exact key is not found, it will try to retrieve:
    - matching nested keys (arbitrarilly deep)
    - keys differing by Symbol vs String type
    - the ith value if the key is an integer i
- Automatic differentiation (AD) friendly constructors
    - `dict` for OrderedDict
    - `namedtuple` for NamedTuple


## Contributors
Paul Shen
pxshen@alumni.stanford.edu
Luminescent AI
