module DeBruijn

import Base: show

using ..Lambdas
import ..Lambdas: freevars, reify, substitute, vartype

export Term,
    Var,
    App,
    Abs,
    freevars,
    reify,
    substitute


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


freevars(t::Term) = freevars_at(0, t)
freevars_at(level::Int, t::Var) = t.index > level ? Set([t.index]) : Set{Index}()
freevars_at(level::Int, t::Abs) = setdiff(freevars_at(level + 1, t.body), Set([t.index]))
freevars_at(level::Int, t::App) = freevars_at(level, t.car) ∪ freevars_at(level, t.cdr)


shift(c::Index, d::Index, t::Var) = (t.index < c) ? t : Var(t.index + d)
shift(c::Index, d::Index, t::Abs) = Abs(t.boundname, shift(c + 1, d, t.body))
shift(c::Index, d::Index, t::App) = App(shift(c, d, t.car), shift(c, d, t.cdr))

"""
    shift(c, d, term) -> Term
Increase indices of free variables in `term`, which are at least as big as `c`, by `d`.
"""
shift

"""
    shift(d, term) -> Term
Increase indices of free variables in `term` by `d`.
"""
shift(d::Index, t::Term) = shift(1, d, t)

substitute(i::Index, s::Term, t::Var) = (t.index == i) ? s : t
substitute(i::Index, s::Term, t::App) = App(substitute(i, s, t.car), substitute(i, s, t.cdr))
substitute(i::Index, s::Term, t::Abs) = Abs(t.boundname, substitute(i + 1, shift(1, s), t.body))

reify(v::Var) = :(Var($(v.index)))
reify(t::Abs) = :(Abs($(reify(t.body))))
reify(t::App) = :(App($(reify(t.car)), $(reify(t.cdr))))

vartype(::Type{<:Term}) = Var
vartype(::Term) = Var

end # module DeBruijn
