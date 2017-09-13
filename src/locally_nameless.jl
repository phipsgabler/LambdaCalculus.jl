import Base: show

abstract type LocallyNamelessTerm <: LambdaTerm end


const LocallyNamelessIndex = Int

struct LocallyNamelessBVar <: LocallyNamelessTerm
    index::LocallyNamelessIndex

    LocallyNamelessBVar(index) = index > 0 ? new(index) : error("index must be greater than 0")
end

struct LocallyNamelessFVar <: LocallyNamelessTerm
    name::Symbol
end

struct LocallyNamelessAbs <: LocallyNamelessTerm
    body::LocallyNamelessTerm
    boundname::Nullable{Symbol}
end

LocallyNamelessAbs(body::LocallyNamelessTerm) = LocallyNamelessAbs(body, Nullable{Symbol}())
LocallyNamelessAbs(boundname::Symbol, body::LocallyNamelessTerm) =
    LocallyNamelessAbs(body, Nullable(boundname))

struct LocallyNamelessApp <: LocallyNamelessTerm
    car::LocallyNamelessTerm
    cdr::LocallyNamelessTerm
end


function Base.show(io::IO, expr::DeBruijnAbs)
    print(io, "(λ", expr.boundname, ".", expr.body, ")")
end

function Base.show(io::IO, expr::DeBruijnApp)
    print(io, "(", expr.car, " ", expr.cdr, ")")
end

function Base.show(io::IO, expr::DeBruijnFVar)
    print(io, expr.name)
end

function Base.show(io::IO, expr::DeBruijnBVar)
    print(io, expr.name)
end

freevars(t::LocallyNamelessFVar) = Set(t)
freevars(t::LocallyNamelessBVar) = Set{LocallyNamelessFVar}()
freevars(t::LocallyNamelessAbs) = freevars(t.body)
freevars(t::LocallyNamelessApp) = union(freevars(t.car), freevars(t.cdr))
