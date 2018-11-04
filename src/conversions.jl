import Base: convert

export restorecontext


"""
    restorecontext(term::DeBruijn.Term)

Construct a `NamingContext` with made-up names for the free variables in `term` (respecting their
actual indices).
"""
function restorecontext(t::DeBruijn.Term; freenamehint = :free, boundnamehint = :x)
    @assert freenamehint != boundnamehint
    m = reduce(max, freevars(t), init = 0)
    NamingContext((Symbol(freenamehint, i) for i = 1:m), namehint = boundnamehint)
end


# Named -> DeBruijn
convert(::Type{DeBruijn.Term}, t::Named.Term) =
    convert(DeBruijn.Term, t, NamingContext(freevars(t)))
convert(::Type{DeBruijn.Term}, v::Named.Var, Γ::NamingContext) =
    let index = findfirst(isequal(v.name), Γ)
        index !== nothing ? DeBruijn.Var(index) : throw(KeyError(v.name))
    end
convert(::Type{DeBruijn.Term}, t::Named.App, Γ::NamingContext) =
    let (Γₗ, Γᵣ) = split(Γ)
        DeBruijn.App(convert(DeBruijn.Term, t.car, Γₗ), convert(DeBruijn.Term, t.cdr, Γᵣ))
    end
convert(::Type{DeBruijn.Term}, t::Named.Abs, Γ::NamingContext) =
        DeBruijn.Abs(convert(DeBruijn.Term, t.body, pushfirst(Γ, t.boundname)))


# Named -> LocallyNameless
convert(::Type{LocallyNameless.Term}, t::Named.Term) =
    convert(LocallyNameless.Term, t, NamingContext(freevars(t)))
convert(::Type{LocallyNameless.Term}, v::Named.Var, Γ::NamingContext, level::Int = 0) =
    let index = findfirst(isequal(v.name), Γ)
        index > level ? LocallyNameless.FVar(Γ[index]) : LocallyNameless.BVar(index)
    end
convert(::Type{LocallyNameless.Term}, t::Named.App, Γ::NamingContext, level::Int = 0) =
    let (Γₗ, Γᵣ) = split(Γ)
        LocallyNameless.App(convert(LocallyNameless.Term, t.car, Γₗ, level),
                            convert(LocallyNameless.Term, t.cdr, Γᵣ, level))
    end
convert(::Type{LocallyNameless.Term}, t::Named.Abs, Γ::NamingContext, level::Int = 0) =
    LocallyNameless.Abs(convert(LocallyNameless.Term, t.body, pushfirst(Γ, t.boundname), level + 1))


# DeBruijn -> Named
convert(::Type{Named.Term}, t::DeBruijn.Term) = convert(Named.Term, t, restorecontext(t))
convert(::Type{Named.Term}, t::DeBruijn.Var, Γ::NamingContext) = Named.Var(Γ[t.index])
convert(::Type{Named.Term}, t::DeBruijn.App, Γ::NamingContext) =
    let (Γₗ, Γᵣ) = split(Γ)
        Named.App(convert(Named.Term, t.car, Γₗ), convert(Named.Term, t.cdr, Γᵣ))
    end
convert(::Type{Named.Term}, t::DeBruijn.Abs, Γ::NamingContext) =
    let (boundname, Γ′) = freshname(Γ)
        Named.Abs(boundname, convert(Named.Term, t.body, Γ′))
    end


# DeBruijn -> LocallyNameless
convert(::Type{LocallyNameless.Term}, t::DeBruijn.Term) =
    convert(LocallyNameless.Term, t, restorecontext(t))
convert(::Type{LocallyNameless.Term}, t::DeBruijn.Var, Γ::NamingContext, level::Int = 0) =
    t.index > level ? LocallyNameless.FVar(Γ[t.index - level]) : LocallyNameless.BVar(t.index)
convert(::Type{LocallyNameless.Term}, t::DeBruijn.App, Γ::NamingContext, level::Int = 0) =
    LocallyNameless.App(convert(LocallyNameless.Term, t.car, Γ, level),
                        convert(LocallyNameless.Term, t.cdr, Γ, level))
convert(::Type{LocallyNameless.Term}, t::DeBruijn.Abs, Γ::NamingContext, level::Int = 0) =
    LocallyNameless.Abs(convert(LocallyNameless.Term, t.body, Γ, level + 1))


# LocallyNameless -> Named
convert(::Type{Named.Term}, t::LocallyNameless.Term) =
    convert(Named.Term, t, NamingContext(freevars(t)))
convert(::Type{Named.Term}, t::LocallyNameless.FVar, Γ::NamingContext) = Named.Var(t.name)
convert(::Type{Named.Term}, t::LocallyNameless.BVar, Γ::NamingContext) = Named.Var(Γ[t.index])
convert(::Type{Named.Term}, t::LocallyNameless.App, Γ::NamingContext) =
    let (Γₗ, Γᵣ) = split(Γ)
        Named.App(convert(Named.Term, t.car, Γₗ), convert(Named.Term, t.cdr, Γᵣ))
    end
convert(::Type{Named.Term}, t::LocallyNameless.Abs, Γ::NamingContext) =
    let (boundname, Γ′) = freshname(Γ)
        Named.Abs(boundname, convert(Named.Term, t.body, Γ′))
    end

# LocallyNameless -> DeBruijn
convert(::Type{DeBruijn.Term}, t::LocallyNameless.Term) =
    convert(DeBruijn.Term, t, NamingContext(freevars(t)))
convert(::Type{DeBruijn.Term}, v::LocallyNameless.BVar, Γ::NamingContext) = DeBruijn.Var(v.index)
convert(::Type{DeBruijn.Term}, v::LocallyNameless.FVar, Γ::NamingContext) =
    let index = findfirst(isequal(v.name), Γ)
        index !== nothing ? DeBruijn.Var(index) : throw(KeyError(v.name))
    end
convert(::Type{DeBruijn.Term}, t::LocallyNameless.App, Γ::NamingContext) =
    let (Γₗ, Γᵣ) = split(Γ)
        DeBruijn.App(convert(DeBruijn.Term, t.car, Γₗ), convert(DeBruijn.Term, t.cdr, Γᵣ))
    end
convert(::Type{DeBruijn.Term}, t::LocallyNameless.Abs, Γ::NamingContext) =
    let (boundname, Γ′) = freshname(Γ)
        DeBruijn.Abs(convert(DeBruijn.Term, t.body, Γ′))
    end

