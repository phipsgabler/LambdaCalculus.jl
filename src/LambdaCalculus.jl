module LambdaCalculus

export AbstractTerm,
    addprime,
    freshname


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


include("common_functions.jl")

include("Named/Named.jl")
include("DeBruijn/DeBruijn.jl")
include("LocallyNameless/LocallyNameless.jl")

include("conversions.jl")


end # module LambdaCalculus
