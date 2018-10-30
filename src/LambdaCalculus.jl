module LambdaCalculus

export AbstractTerm,
    addprime,
    freshname


abstract type AbstractTerm end

include("common_functions.jl")
include("naming_context.jl")

include("Named/Named.jl")
include("DeBruijn/DeBruijn.jl")
include("LocallyNameless/LocallyNameless.jl")

include("conversions.jl")


end # module LambdaCalculus
