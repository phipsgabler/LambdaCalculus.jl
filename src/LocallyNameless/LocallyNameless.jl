module LocallyNameless

import Base: show

using ..LambdaCalculus
import ..LambdaCalculus: boundvartype, freevartype, reify

const Index = Int

abstract type Term <: AbstractTerm end

struct BVar <: Term
    index::Index
    BVar(index) = index > 0 ? new(index) : error("index must be greater than 0")
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


boundvartype(::Type{<:Term}) = BVar
freevartype(::Type{<:Term}) = FVar


include("syntactic.jl")


end # module LocallyNameless
