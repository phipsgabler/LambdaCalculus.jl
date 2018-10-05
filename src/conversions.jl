import Base: convert

equivalent_type(::Type{DeBruijn.Term}) = Named.Term
equivalent_type(::Type{DeBruijn.Var}) = Named.Var
equivalent_type(::Type{DeBruijn.App}) = Named.App
equivalent_type(::Type{DeBruijn.Abs}) = Named.Abs
equivalent_type(::Type{Named.Term}) = DeBruijn.Term
equivalent_type(::Type{Named.Var}) = DeBruijn.Var
equivalent_type(::Type{Named.App}) = DeBruijn.App
equivalent_type(::Type{Named.Abs}) = DeBruijn.Abs


convert(::Type{<:DeBruijn.Term}, t::Named.Term) = convert(DeBruijn.Term, t, collect(freevars(t)))
convert(::Type{DeBruijn.Term}, t::NT, ctx::Vector{Symbol}) where {NT<:Named.Term} =
    convert(equivalent_type(NT), t, ctx)
convert(::Type{DeBruijn.Var}, v::Named.Var, ctx::Vector{Symbol}) =
    DeBruijn.Var(findfirst(isequal(v.name), ctx))
convert(::Type{DeBruijn.App}, t::Named.App, ctx::Vector{Symbol}) =
    DeBruijn.App(convert(DeBruijn.Term, t.car, ctx), convert(DeBruijn.Term, t.cdr, ctx))
convert(::Type{DeBruijn.Abs}, t::Named.Abs, ctx::Vector{Symbol}) =
    DeBruijn.Abs(convert(DeBruijn.Term, t.body, [t.boundname; ctx]))

convert(::Type{Named.Term}, t::DT, ctx::Vector{Symbol}) where {DT<:DeBruijn.Term} =
    convert(equivalent_type(DT), t, ctx)
convert(::Type{Named.Var}, t::DeBruijn.Var, ctx::Vector{Symbol}) = Named.Var(ctx[t.index])
convert(::Type{Named.App}, t::DeBruijn.App, ctx::Vector{Symbol}) =
    Named.App(convert(Named.Term, t.car, ctx), convert(Named.Term, t.cdr, ctx))
convert(::Type{Named.Abs}, t::DeBruijn.Abs, ctx::Vector{Symbol}) =
    Named.Abs(ctx[1], convert(Named.Term, t.body, ctx[2:end]))
