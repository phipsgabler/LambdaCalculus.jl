module DeBruijn

import Base: length, show

using ..LambdaCalculus
import ..LambdaCalculus: freevars, reify, vartype

export Term,
    Var,
    App,
    Abs,
    freevars,
    reify


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


freevars(t::Term) = freevars_at(0, t)
freevars_at(level::Int, t::Var) = t.index > level ? Set([t.index]) : Set{Index}()
freevars_at(level::Int, t::Abs) = setdiff(freevars_at(level + 1, t.body), Set([t]))
freevars_at(level::Int, t::App) = freevars_at(level, t.car) ∪ freevars_at(level, t.cdr)

reify(v::Var) = :(Var($(v.index)))
reify(t::Abs) = :(Abs($(reify(t.body))))
reify(t::App) = :(App($(reify(t.car)), $(reify(t.cdr))))

vartype(::Type{<:Term}) = Var
vartype(::Term) = Var


include("debruijn_evaluate.jl")

end # module DeBruijn
