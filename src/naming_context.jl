import Base: ==, cat, collect, copy, eltype, filter, first, firstindex, getindex,
    in, isempty, iterate, keys, last, lastindex, length, map, pairs, show
#append!, delete!, pop!, popfirst!, push!, pushfirst!, setindex!

export NamingContext,
    freenames,
    pushfirst,
    freshname

struct NamingContext{T}
    freenames::Vector{T}
end

NamingContext(freenames) = NamingContext{eltype(freenames)}(collect(freenames))

freenames(Γ::NamingContext) = Γ.freenames


==(Γ₁::NamingContext, Γ₂::NamingContext) = Γ₁.freenames == Γ₂.freenames
cat(Γ₁::NamingContext, Γs::NamingContext...) =
    NamingContext(cat(Γ₁.freenames, freenames.(Γs)...))
collect(Γ::NamingContext) = Γ.freenames
copy(Γ::NamingContext) = NamingContext(copy(Γ.freenames))
eltype(::Type{NamingContext{T}}) where T = T
first(Γ::NamingContext) = firstindex(Γ.freenames)
firstindex(Γ::NamingContext) = firstindex(Γ.freenames)
filter(f, Γ::NamingContext) = NamingContext(filter(f, Γ.freenames))
getindex(Γ::NamingContext, key) = getindex(Γ.freenames, reverseind(Γ.freenames, key))
in(name, Γ::NamingContext) = name in Γ.freenames
isempty(Γ::NamingContext) = isempty(Γ.freenames)
keys(Γ::NamingContext) = keys(Γ.freenames)
last(Γ::NamingContext) = last(Γ.freenames)
lastindex(Γ::NamingContext) = lastindex(Γ.freenames)
length(Γ::NamingContext) = length(Γ.freenames)
map(f, Γs::NamingContext...) = NamingContext(map(f, freenames.(Γs)...))
pairs(Γ::NamingContext) = zip(keys(Γ.freenames), Iterators.reverse(Γ.freenames))

function show(io::IO, Γ::NamingContext{T}) where T
    print(io, "NamingContext{", T, "}([")
    join(io, reverse(sprint.(show, Γ.freenames)), ", ")
    print(io, "])")
end


pushfirst(Γ::NamingContext, items...) = NamingContext([Γ.freenames; collect(items)])


addprime(s::String, n = 1) = string(s, "′" ^ n)
addprime(s::Symbol, n = 1) = Symbol(addprime(string(s), n))

"Generate a new name based on `name`, which does not occur in `fv`."
function freshname(name::T, Γ::NamingContext{T}) where T
    freshname = name
    primes = 0
    
    while freshname ∈ Γ
        freshname = addprime(name, primes)
        primes += 1
    end

    return freshname
end
