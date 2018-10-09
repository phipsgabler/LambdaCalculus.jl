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


"""
    freevars(t::Term) -> Set

Calculate the set of free variables in `t`.
"""
function freevars end


"""
    reify(t::Term) -> Expr

Construct an expression which, when evaluated, returns `t`.
"""
function reify end


include("named.jl")
include("debruijn.jl")
# include("locally_nameless.jl")

include("conversions.jl")
include("meta.jl")
include("common_functions.jl")


end # module
