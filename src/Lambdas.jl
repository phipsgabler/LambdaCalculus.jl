module Lambdas

abstract type LambdaTerm end

include("named.jl")
include("debruijn.jl")
include("locally_named.jl")

end # module
