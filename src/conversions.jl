const N = Lambdas.Named
const D = Lambdas.DeBruijn

import Base: convert

equivalent_type(::Type{D.Term}) = N.Term
equivalent_type(::Type{D.Var}) = N.Var
equivalent_type(::Type{D.App}) = N.App
equivalent_type(::Type{D.Abs}) = N.Abs
equivalent_type(::Type{N.Term}) = D.Term
equivalent_type(::Type{N.Var}) = D.Var
equivalent_type(::Type{N.App}) = D.App
equivalent_type(::Type{N.Abs}) = D.Abs


convert(::Type{<:D.Term}, t::N.Term) = convert(D.Term, t, collect(freevars(t)))
convert(::Type{D.Term}, t::NT, ctx::Vector{Symbol}) where {NT<:N.Term} =
    convert(equivalent_type(NT), t, ctx)
convert(::Type{D.Var}, v::N.Var, ctx::Vector{Symbol}) = D.Var(findfirst(isequal(v.name), ctx))
convert(::Type{D.App}, t::N.App, ctx::Vector{Symbol}) =
    D.App(convert(D.Term, t.car, ctx), convert(D.Term, t.cdr, ctx))
convert(::Type{D.Abs}, t::N.Abs, ctx::Vector{Symbol}) =
    D.Abs(convert(D.Term, t.body, [t.boundname; ctx]))

# convert(::Type{NT}, t::D.Term, ctx::Vector{Symbol}) where {NT<:N.Term} = convert(NT, t, ctx)
convert(::Type{N.Term}, t::DT, ctx::Vector{Symbol}) where {DT<:D.Term} =
    convert(equivalent_type(DT), t, ctx)
convert(::Type{N.Var}, t::D.Var, ctx::Vector{Symbol}) = N.Var(ctx[t.index])
convert(::Type{N.App}, t::D.App, ctx::Vector{Symbol}) =
    N.App(convert(N.Term, t.car, ctx), convert(N.Term, t.cdr, ctx))
convert(::Type{N.Abs}, t::D.Abs, ctx::Vector{Symbol}) =
    N.Abs(ctx[1], convert(N.Term, t.body, ctx[2:end]))
