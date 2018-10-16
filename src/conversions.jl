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
convert(::Type{DeBruijn.Term}, t::NT, fv::Vector{Symbol}) where {NT<:Named.Term} =
    convert(equivalent_type(NT), t, fv)
convert(::Type{DeBruijn.Var}, v::Named.Var, fv::Vector{Symbol}) =
    DeBruijn.Var(findlast(isequal(v.name), fv))
convert(::Type{DeBruijn.App}, t::Named.App, fv::Vector{Symbol}) =
    DeBruijn.App(convert(DeBruijn.Term, t.car, fv), convert(DeBruijn.Term, t.cdr, fv))
convert(::Type{DeBruijn.Abs}, t::Named.Abs, fv::Vector{Symbol}) =
    DeBruijn.Abs(convert(DeBruijn.Term, t.body, [t.boundname; fv]))


convert(::Type{Named.Term}, t::DT, fv::Vector{Symbol}) where {DT<:DeBruijn.Term} =
    convert(equivalent_type(DT), t, fv)
convert(::Type{Named.Var}, t::DeBruijn.Var, fv::Vector{Symbol}) = Named.Var(fv[t.index])
convert(::Type{Named.App}, t::DeBruijn.App, fv::Vector{Symbol}) =
    Named.App(convert(Named.Term, t.car, fv), convert(Named.Term, t.cdr, fv))
convert(::Type{Named.Abs}, t::DeBruijn.Abs, fv::Vector{Symbol}) =
    let boundname = freshname(:x, fv)
        Named.Abs(boundname, convert(Named.Term, t.body, [boundname; fv]))
    end
