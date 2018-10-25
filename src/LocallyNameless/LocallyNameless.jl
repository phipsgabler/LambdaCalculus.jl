module LocallyNameless

using Reexport
@reexport using ..LambdaCalculus

import Base: show
import ..LambdaCalculus: boundvartype, freevartype, reify

export Index,
    Term,
    BVar,
    FVar,
    Abs,
    App


const Index = Int

abstract type Term <: AbstractTerm end

struct BVar <: Term
    index::Index
    BVar(index) = index ≥ 1 ? new(index) : error("index must be at least 1")
end

struct FVar <: Term
    name::Symbol
end

struct Abs <: Term
    # boundname::Union{Symbol, Nothing}
    body::Term
end

struct App <: Term
    car::Term
    cdr::Term
end


show(io::IO, t::Abs) = print(io, "(λ.", t.body, ")")
show(io::IO, t::App) = print(io, "(", t.car, " ", t.cdr, ")")
show(io::IO, t::FVar) = print(io, t.name)
show(io::IO, t::BVar) = print(io, "⟨", t.index, "⟩")


reify(f::FVar) = :(FVar($(f.name)))
reify(b::BVar) = :(BVar($(b.index)))
reify(t::Abs) = :(Abs($(reify(t.body))))
reify(t::App) = :(App($(reify(t.car)), $(reify(t.cdr))))


boundvartype(::Type{<:Term}) = BVar
freevartype(::Type{<:Term}) = FVar


include("syntactic.jl")


end # module LocallyNameless
