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
convert(::Type{DeBruijn.Term}, t::NT, Γ::NamingContext) where {NT<:Named.Term} =
    convert(equivalent_type(NT), t, Γ)
convert(::Type{DeBruijn.Var}, v::Named.Var, Γ::NamingContext) =
    let index = findfirst(isequal(v.name), Γ)
        index !== nothing || throw(KeyError(v.name))
        DeBruijn.Var(index)
    end
convert(::Type{DeBruijn.App}, t::Named.App, Γ::NamingContext) =
    let (Γₗ, Γᵣ) = split(Γ)
        DeBruijn.App(convert(DeBruijn.Term, t.car, Γₗ), convert(DeBruijn.Term, t.cdr, Γᵣ))
    end
convert(::Type{DeBruijn.Abs}, t::Named.Abs, Γ::NamingContext) =
        DeBruijn.Abs(convert(DeBruijn.Term, t.body, pushfirst(Γ, t.boundname)))


convert(::Type{Named.Term}, t::DT, Γ::NamingContext) where {DT<:DeBruijn.Term} =
    convert(equivalent_type(DT), t, Γ)
convert(::Type{Named.Var}, t::DeBruijn.Var, Γ::NamingContext) = Named.Var(Γ[t.index])
convert(::Type{Named.App}, t::DeBruijn.App, Γ::NamingContext) =
    let (Γₗ, Γᵣ) = split(Γ)
        Named.App(convert(Named.Term, t.car, Γₗ), convert(Named.Term, t.cdr, Γᵣ))
    end
convert(::Type{Named.Abs}, t::DeBruijn.Abs, Γ::NamingContext) =
    let (boundname, Γ′) = freshname(Γ)
        Named.Abs(boundname, convert(Named.Term, t.body, Γ′))
    end
