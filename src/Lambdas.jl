module Lambdas

export AbstractTerm,
    freshname,
    addprime,
    freevars


abstract type AbstractTerm end

addprime(s::String, n = 1) = string(s, "′" ^ n)
addprime(s::Symbol, n = 1) = Symbol(addprime(string(s), n))

function freshname(name, fv)
    freshname = name
    primes = 0
    
    while freshname ∈ fv
        freshname = addprime(name, primes)
        primes += 1
    end

    return freshname
end

function freevars end


include("named.jl")
include("debruijn.jl")
# include("locally_nameless.jl")

include("conversions.jl")
include("meta.jl")
include("common_functions.jl")


end # module
