import Base: ==, checkbounds, collect, eltype, filter, first, firstindex, getindex,
    in, isempty, iterate, keys, last, lastindex, length, map, pairs, show,
    IteratorEltype, IteratorSize

export Name,
    NameList,
    NamingContext,
    freenames,
    pushfirst,
    freshnames

const Name = Symbol


struct UniqueIndices
    start::Int
    log_skip::Int
end

nextindex(u::UniqueIndices) = UniqueIndices(u.start + 2^u.log_skip, u.log_skip)

function splitindex(u::UniqueIndices)
    left = UniqueIndices(u.start, u.log_skip + 1)
    right = UniqueIndices(u.start + 2^u.log_skip, u.log_skip + 1)
    (left, right)
end


struct NamingContext
    freenames::Vector{Name}
    namehint::Name
    indices::UniqueIndices
end

NamingContext(freenames = Name[]; namehint = :x) =
    NamingContext(collect(freenames), namehint, UniqueIndices(1, 0))

freenames(Γ::NamingContext) = Γ.freenames


==(Γ₁::NamingContext, Γ₂::NamingContext) = Γ₁.freenames == Γ₂.freenames
checkbounds(::Type{Bool}, Γ::NamingContext, i::Int) = firstindex(Γ) ≤ i ≤ lastindex(Γ)
# cat(Γ₁::NamingContext, Γs::NamingContext...) =
#     NamingContext(cat(Γ₁.freenames, freenames.(Γs)...))
collect(Γ::NamingContext) = Γ.freenames
# copy(Γ::NamingContext) = NamingContext(copy(Γ.freenames))
eltype(::Type{NamingContext}) = Symbol
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

function show(io::IO, Γ::NamingContext)
    print(io, "NamingContext([")
    join(io, reverse(sprint.(show, Γ.freenames)), ", ")
    print(io, "])")
end




struct FreshNames
    Γ::NamingContext
end

iterate(iter::FreshNames) = iterate(iter, iter.Γ.indices)
function iterate(iter::FreshNames, state)
    while true
        newname = Symbol(iter.Γ.namehint, state.start)
        if newname ∉ iter.Γ.freenames
            return newname, nextindex(state)
        end
        indices = nextindex(indices)
    end
end

IteratorSize(::Type{FreshNames}) = Base.IsInfinite()
IteratorEltype(::Type{FreshNames}) = Base.HasEltype()
eltype(::Type{FreshNames}) = Symbol

freshnames(Γ::NamingContext) = FreshNames(Γ)



pushfirst(Γ::NamingContext, names...) =
    NamingContext([Γ.freenames; names...], Γ.namehint, Γ.indices)

function freshname(Γ::NamingContext)
    (newname, newindex) = iterate(FreshNames(Γ))
    Γ′ = NamingContext([Γ.freenames; newname], Γ.namehint, newindex)
    (newname, Γ′)
end

function split(Γ::NamingContext)
    l, r = splitindex(Γ.indices)
    NamingContext(Γ.freenames, Γ.namehint, l), NamingContext(Γ.freenames, Γ.namehint, r)
end
