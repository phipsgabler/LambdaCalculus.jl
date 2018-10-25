module DeBruijn

using Reexport
@reexport using ..LambdaCalculus

import Base: length, show
import ..LambdaCalculus: boundvartype, freevartype, reify

export App,
    Abs,
    Index,
    Term,
    Var


const Index = Int


"""Lambda terms using [De Bruijn indexing](De Bruijn indexing), built using only the following rule:

    <Term> := <Number>            (variable)
            | λ <Term>            (abstraction)
            | (<Term> <Term>)     (application)

Each De Bruijn index is a natural number that represents an occurrence of a variable in a ``λ``-term,
and denotes the number of binders that are in scope between that occurrence and its corresponding
binder.

!!! warning "Important note"

    Since we are in Julia, indices start at ``1``.
"""
abstract type Term <: AbstractTerm end

struct Var <: Term
    index::Index

    Var(index) = index ≥ 1 ? new(index) : error("index must be at least 1")
end

struct Abs <: Term
    body::Term
end

struct App <: Term
    car::Term
    cdr::Term
end


show(io::IO, t::Abs) = print(io, "(λ", ".", t.body, ")")
show(io::IO, t::App) = print(io, "(", t.car, " ", t.cdr, ")")
show(io::IO, t::Var) = print(io, t.index)

length(t::Var) = t.index + 1
length(t::App) = length(t.car) + length(t.cdr) + 2
length(t::Abs) = length(t.body) + 2

reify(v::Var) = :(Var($(v.index)))
reify(t::Abs) = :(Abs($(reify(t.body))))
reify(t::App) = :(App($(reify(t.car)), $(reify(t.cdr))))

freevartype(::Type{<:Term}) = Var
boundvartype(::Type{<:Term}) = Var


include("syntactic.jl")
include("meta.jl")

end # module DeBruijn
