import Base: convert

export restorecontext

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
    convert(LocallyNameless.Term, t, NamingContext())
convert(::Type{LocallyNameless.Term}, v::Named.Var, Γ::NamingContext) =
    let index = findfirst(isequal(v.name), Γ)
        index !== nothing ? LocallyNameless.BVar(index) : LocallyNameless.FVar(v.name)
    end
convert(::Type{LocallyNameless.Term}, t::Named.App, Γ::NamingContext) =
    let (Γₗ, Γᵣ) = split(Γ)
        LocallyNameless.App(convert(LocallyNameless.Term, t.car, Γₗ),
                            convert(LocallyNameless.Term, t.cdr, Γᵣ))
    end
convert(::Type{LocallyNameless.Term}, t::Named.Abs, Γ::NamingContext) =
        LocallyNameless.Abs(convert(LocallyNameless.Term, t.body, pushfirst(Γ, t.boundname)))


# DeBruijn -> Named
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
"""
    restorecontext(term::DeBruijn.Term)

Construct a `NamingContext` with made-up names for the free variables in `term` (respecting their
actual indices).
"""
function restorecontext(t::DeBruijn.Term; freenamehint = :free, boundnamehint = :x)
    @assert freenamehint != boundnamehint
    m = maximum(freevars(t))
    NamingContext((Symbol(freenamehint, i) for i = 1:m), namehint = boundnamehint)
end

convert(::Type{LocallyNameless.Term}, t::DeBruijn.Term) =
    convert(LocallyNameless.Term, t, restorecontext(t), 0)
convert(::Type{LocallyNameless.Term}, t::DeBruijn.Var, Γ::NamingContext, level::Int) =
    t.index > level ? LocallyNameless.FVar(Γ[t.index - level]) : LocallyNameless.BVar(t.index)
convert(::Type{LocallyNameless.Term}, t::DeBruijn.App, Γ::NamingContext, level::Int) =
    LocallyNameless.App(convert(LocallyNameless.Term, t.car, Γ, level),
                        convert(LocallyNameless.Term, t.cdr, Γ, level))
convert(::Type{LocallyNameless.Term}, t::DeBruijn.Abs, Γ::NamingContext, level::Int) =
    LocallyNameless.Abs(convert(LocallyNameless.Term, t.body, Γ, level + 1))
