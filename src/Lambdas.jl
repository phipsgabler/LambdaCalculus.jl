module Lambdas

export AbstractTerm,
    addprime,
    freevars,
    freshname,
    substitute,
    reify,
    vartype


abstract type AbstractTerm end

addprime(s::String, n = 1) = string(s, "′" ^ n)
addprime(s::Symbol, n = 1) = Symbol(addprime(string(s), n))

"Generate a new name based on `name`, which does not occur in `fv`."
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
    substitute(v, s::Term, t::Term) -> Term

Capture-avoiding substitution of variable `v` in `t` by `s`, commonly written like `t[v -> s]`.
Will rename bound variables, if required.
"""
function substitute end

getindex(t::T, subst::Pair{<:Any, <:T}) where {T} = substitute(subst[1], subst[2], t)


"""
    reify(t::Term) -> Expr

Construct an expression which, when evaluated, returns `t`.
"""
function reify end


"""
    vartype(type) -> Type

Determine the type of (free) variables used in term type `type`.
"""
function vartype end


include("named.jl")
include("debruijn.jl")
# include("locally_nameless.jl")

include("conversions.jl")
include("meta.jl")
include("common_functions.jl")


end # module
