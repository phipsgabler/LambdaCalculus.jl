module Lambdas

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


export AbstractTerm,
    freshname,
    addprime,
    freevars


include("named.jl")

include("debruijn.jl")

# include("locally_nameless.jl")

include("conversions.jl")


end # module
