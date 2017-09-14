import Base: show

export LocallyNamelessRepr,
    LocallyNamelessFVar,
    LocallyNamelessBVar,
    LocallyNamelessApp,
    LocallyNamelessAbs,
    openterm,
    closeterm,
    substitute,
    freevars


const LocallyNamelessIndex = Int

abstract type LocallyNamelessRepr end

struct LocallyNamelessBVar <: LocallyNamelessRepr
    index::LocallyNamelessIndex

    LocallyNamelessBVar(index) = index > 0 ? new(index) : error("index must be greater than 0")
end

struct LocallyNamelessFVar <: LocallyNamelessRepr
    name::Symbol
end

struct LocallyNamelessAbs <: LocallyNamelessRepr
    boundname::Nullable{Symbol}
    body::LocallyNamelessRepr
end

LocallyNamelessAbs(body::LocallyNamelessRepr) = LocallyNamelessAbs(Nullable{Symbol}(), body)
LocallyNamelessAbs(boundname::Symbol, body::LocallyNamelessRepr) =
    LocallyNamelessAbs(Nullable(boundname), body)

struct LocallyNamelessApp <: LocallyNamelessRepr
    car::LocallyNamelessRepr
    cdr::LocallyNamelessRepr
end

const LocallyNamelessContext = Dict{Symbol, Int}

struct LocallyNamelessTerm <: LambdaTerm
    representation::LocallyNamelessRepr
    context::LocallyNamelessContext
end


function Base.show(io::IO, t::LocallyNamelessAbs)
    if isnull(t.boundname)
        print(io, "(λ.", t.body, ")")
    else
        print(io, "(λ{", get(t.boundname), "}.", t.body, ")")
    end
end

function Base.show(io::IO, t::LocallyNamelessApp)
    print(io, "(", t.car, " ", t.cdr, ")")
end

function Base.show(io::IO, t::LocallyNamelessFVar)
    print(io, t.name)
end

function Base.show(io::IO, t::LocallyNamelessBVar)
    print(io, t.index)
end


freevars(t::LocallyNamelessFVar) = Set([t])
freevars(t::LocallyNamelessBVar) = Set{LocallyNamelessFVar}()
freevars(t::LocallyNamelessAbs) = freevars(t.body)
freevars(t::LocallyNamelessApp) = union(freevars(t.car), freevars(t.cdr))


openterm(i::LocallyNamelessIndex, s::LocallyNamelessRepr, t::LocallyNamelessBVar) =
    t.index == i ? s : t
openterm(i::LocallyNamelessIndex, s::LocallyNamelessRepr, t::LocallyNamelessFVar) = t
openterm(i::LocallyNamelessIndex, s::LocallyNamelessRepr, t::LocallyNamelessApp) =
    LocallyNamelessApp(openterm(i, s, t.car), openterm(i, s, t.cdr))
openterm(i::LocallyNamelessIndex, s::LocallyNamelessRepr, t::LocallyNamelessAbs) =
    LocallyNamelessAbs(t.boundname, openterm(i + 1, s, t.body))
openterm(s::LocallyNamelessRepr, t::LocallyNamelessRepr) = openterm(1, s, t)

closeterm(i::LocallyNamelessIndex, x::Symbol, t::LocallyNamelessBVar) = t
closeterm(i::LocallyNamelessIndex, x::Symbol, t::LocallyNamelessFVar) = 
    t.index == i ? LocallyNamelessBVar(i) : t
closeterm(i::LocallyNamelessIndex, x::Symbol, t::LocallyNamelessApp) =
    LocallyNamelessApp(closeterm(i, x, t.car), closeterm(i, x, t.cdr))
closeterm(i::LocallyNamelessIndex, x::Symbol, t::LocallyNamelessAbs) =
    LocallyNamelessAbs(t.boundname, closeterm(i + 1, x, t.body))
closeterm(x::Symbol, t::LocallyNamelessRepr) = closeterm(1, x, t)

substitute(x::Symbol, s::LocallyNamelessRepr, t::LocallyNamelessBVar) = t
substitute(x::Symbol, s::LocallyNamelessRepr, t::LocallyNamelessFVar) = t.name == x ? s : t
substitute(x::Symbol, s::LocallyNamelessRepr, t::LocallyNamelessApp) =
    LocallyNamelessApp(substitute(x, s, t.car), substitute(x, s, t.cdr))
substitute(x::Symbol, s::LocallyNamelessRepr, t::LocallyNamelessAbs) =
    LocallyNamelessAbs(t.boundname, substitute(x, s, t.body))

