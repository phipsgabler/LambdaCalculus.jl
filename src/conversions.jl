import Base: convert

equivalent_type(::Type{DeBruijn.Term}) = Named.Term
equivalent_type(::Type{DeBruijn.Var}) = Named.Var
equivalent_type(::Type{DeBruijn.App}) = Named.App
equivalent_type(::Type{DeBruijn.Abs}) = Named.Abs
equivalent_type(::Type{Named.Term}) = DeBruijn.Term
equivalent_type(::Type{Named.Var}) = DeBruijn.Var
equivalent_type(::Type{Named.App}) = DeBruijn.App
equivalent_type(::Type{Named.Abs}) = DeBruijn.Abs


convert(::Type{<:DeBruijn.Term}, t::Named.Term) =
    convert(DeBruijn.Term, t, NamingContext(freevars(t)))
convert(::Type{DeBruijn.Term}, t::NT, Γ::NamingContext{Symbol}) where {NT<:Named.Term} =
    convert(equivalent_type(NT), t, Γ)
convert(::Type{DeBruijn.Var}, v::Named.Var, Γ::NamingContext{Symbol}) =
    let index = findfirst(isequal(v.name), Γ)
        index !== nothing || throw(KeyError(v.name))
        DeBruijn.Var(index)
    end
convert(::Type{DeBruijn.App}, t::Named.App, Γ::NamingContext{Symbol}) =
    DeBruijn.App(convert(DeBruijn.Term, t.car, Γ), convert(DeBruijn.Term, t.cdr, Γ))
convert(::Type{DeBruijn.Abs}, t::Named.Abs, Γ::NamingContext{Symbol}) =
        DeBruijn.Abs(convert(DeBruijn.Term, t.body, pushfirst(Γ, t.boundname)))


convert(::Type{Named.Term}, t::DT, Γ::NamingContext{Symbol}) where {DT<:DeBruijn.Term} =
    convert(equivalent_type(DT), t, Γ)
convert(::Type{Named.Var}, t::DeBruijn.Var, Γ::NamingContext{Symbol}) = Named.Var(Γ[t.index])
convert(::Type{Named.App}, t::DeBruijn.App, Γ::NamingContext{Symbol}) =
    Named.App(convert(Named.Term, t.car, Γ), convert(Named.Term, t.cdr, Γ))
convert(::Type{Named.Abs}, t::DeBruijn.Abs, Γ::NamingContext{Symbol}) =
    let boundname = freshname(:x, Γ)
        Named.Abs(boundname, convert(Named.Term, t.body, pushfirst(Γ, boundname)))
    end
