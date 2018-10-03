import Base: show

export DeBruijnRepr,
    DeBruijnVar,
    DeBruijnApp,
    DeBruijnAbs,
    freevars,
    shift,
    substitute

const DeBruijnIndex = Int

abstract type DeBruijnRepr end

struct DeBruijnVar <: DeBruijnRepr
    index::DeBruijnIndex

    DeBruijnVar(index) = index > 0 ? new(index) : error("index must be greater than 0")
end

struct DeBruijnAbs <: DeBruijnRepr
    boundname::Symbol
    body::DeBruijnRepr
end

# DeBruijnAbs(body::DeBruijnRepr) = DeBruijnAbs(Nullable{Symbol}(), body)
# DeBruijnAbs(boundname::Symbol, body::DeBruijnRepr) = DeBruijnAbs(boundname, body)

struct DeBruijnApp <: DeBruijnRepr
    car::DeBruijnRepr
    cdr::DeBruijnRepr
end

const DeBruijnContext = Dict{Int, Symbol}


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
struct DeBruijnTerm <: LambdaTerm
    representation::DeBruijnRepr
    context::DeBruijnContext
end


function show(io::IO, t::DeBruijnAbs)
    print(io, "(λ{", t.boundname, "}.", t.body, ")")
end

function show(io::IO, t::DeBruijnApp)
    print(io, "(", t.car, " ", t.cdr, ")")
end

function show(io::IO, t::DeBruijnVar)
    print(io, t.index)
end


freevars(t::DeBruijnRepr) = freevars_at(0, t)
freevars_at(level::Int, t::DeBruijnVar) = t.index > level ? Set([t]) : Set{DeBruijnVar}()
freevars_at(level::Int, t::DeBruijnAbs) = setdiff(freevars_at(level + 1, t.body), Set([t]))
freevars_at(level::Int, t::DeBruijnApp) = union(freevars_at(level, t.car), freevars_at(level, t.cdr))


shift(c::DeBruijnIndex, d::DeBruijnIndex, t::DeBruijnVar) =
    (t.index < c) ? t : DeBruijnVar(t.index + d)
shift(c::DeBruijnIndex, d::DeBruijnIndex, t::DeBruijnAbs) =
    DeBruijnAbs(t.boundname, shift(c + 1, d, t.body))
shift(c::DeBruijnIndex, d::DeBruijnIndex, t::DeBruijnApp) =
    DeBruijnApp(shift(c, d, t.car), shift(c, d, t.cdr))
shift(d::DeBruijnIndex, t::DeBruijnRepr) = shift(1, d, t)

substitute(i::DeBruijnIndex, s::DeBruijnRepr, t::DeBruijnVar) = (t.index == i) ? s : t
substitute(i::DeBruijnIndex, s::DeBruijnRepr, t::DeBruijnApp) =
    DeBruijnApp(substitute(i, s, t.car), substitute(i, s, t.cdr))
substitute(i::DeBruijnIndex, s::DeBruijnRepr, t::DeBruijnAbs) =
    DeBruijnAbs(t.boundname, substitute(i + 1, shift(1, s), t.body))

