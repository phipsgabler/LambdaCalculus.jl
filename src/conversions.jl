import Base: get

export named2debruijn,
    debruijn2named,
    named2locallynameless,
    locallynameless2named,
    normalizenames

@inline function get(default::F, x::Union{T, Nothing}) where {F, T}
    if x === nothing
        return default()
    else
        return x
    end    
end


function named2debruijn(t::NamedTerm)
    fv = [v.name for v in freevars(t)]
    named2debruijn(t, fv), fv
end

named2debruijn(t::NamedVar, ctx::Vector{Symbol}) =
    DeBruijnVar(findfirst(ctx, t.name))
named2debruijn(t::NamedApp, ctx::Vector{Symbol}) =
    DeBruijnApp(named2debruijn(t.car, ctx), named2debruijn(t.cdr, ctx))
named2debruijn(t::NamedAbs, ctx::Vector{Symbol}) =
    DeBruijnAbs(t.boundname, named2debruijn(t.body, [t.boundname; ctx]))

debruijn2named(t::DeBruijnVar, ctx::Vector{Symbol}) =
    NamedVar(ctx[t.index])
debruijn2named(t::DeBruijnApp, ctx::Vector{Symbol}) =
    NamedApp(debruijn2named(t.car, ctx), debruijn2named(t.cdr, ctx))
debruijn2named(t::DeBruijnAbs, ctx::Vector{Symbol}) =
    NamedAbs(t.boundname, debruijn2named(t.body, [t.boundname; ctx]))



function named2locallynameless(t::NamedTerm)
    fv = [v.name for v in freevars(t)]
    named2locallynameless(t, Symbol[])
end
function named2locallynameless(t::NamedVar, bv::Vector{Symbol})
    i = findfirst(bv, t.name)
    if i != 0
        LocallyNamelessBVar(i)
    else
        LocallyNamelessFVar(t.name)
    end
end
named2locallynameless(t::NamedApp, bv::Vector{Symbol}) =
    LocallyNamelessApp(named2locallynameless(t.car, bv), named2locallynameless(t.cdr, bv))
named2locallynameless(t::NamedAbs, bv::Vector{Symbol}) =
    LocallyNamelessAbs(t.boundname, named2locallynameless(t.body, [t.boundname; bv]))

locallynameless2named(t::LocallyNamelessBVar, ctx::Vector{Symbol}) =
    NamedVar(ctx[t.index])
locallynameless2named(t::LocallyNamelessFVar, ctx::Vector{Symbol}) =
    NamedVar(t.name)
locallynameless2named(t::LocallyNamelessApp, ctx::Vector{Symbol}) =
    NamedApp(locallynameless2named(t.car, ctx), locallynameless2named(t.cdr, ctx))
function locallynameless2named(t::LocallyNamelessAbs, ctx::Vector{Symbol})
    freshname = get(t.boundname) do
        candidate = :x
        while candidate ∈ ctx
            candidate = Symbol(candidate, "′")
        end
        candidate
    end
    NamedAbs(freshname, locallynameless2named(t.body, [freshname; ctx]))
end
