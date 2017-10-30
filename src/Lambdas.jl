module Lambdas

abstract type LambdaTerm end

include("named.jl")
include("debruijn.jl")
include("locally_nameless.jl")
include("conversions.jl")



end # module
