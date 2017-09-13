import Base: show

abstract type DeBruijnTerm <: LambdaTerm end

const DeBruijnIndex = Int

struct DeBruijnVar <: DeBruijnTerm
    index::DeBruijnIndex

    DeBruijnVar(index) = index > 0 ? new(index) : error("index must be greater than 0")
end

struct DeBruijnAbs <: DeBruijnTerm
    body::DeBruijnTerm
    boundname::Nullable{Symbol}
end

DeBruijnAbs(body::DeBruijnTerm) = DeBruijnAbs(body, Nullable{Symbol}())
DeBruijnAbs(boundname::Symbol, body::DeBruijnTerm) = DeBruijnAbs(body, Nullable(boundname))

struct DeBruijnApp <: DeBruijnTerm
    car::DeBruijnTerm
    cdr::DeBruijnTerm
end


function Base.show(io::IO, expr::DeBruijnAbs)
    if isnull(expr.boundname)
        print(io, "(λ.", expr.body, ")")
    else
        print(io, "(λ{", get(expr.boundname), "}.", expr.body, ")")
    end
end

function Base.show(io::IO, expr::DeBruijnApp)
    print(io, "(", expr.car, " ", expr.cdr, ")")
end

function Base.show(io::IO, expr::DeBruijnVar)
    print(io, "{", get(expr.name), ":", expr.index, "}")
end


freevars(t::DeBruijnTerm) = freevars_at(0, t)
freevars_at(level::Int, t::DeBruijnVar) = t.index > level ? Set(t) : Set{DeBruijnVar}()
freevars_at(level::Int, t::DeBruijnAbs) = setdiff(freevars_at(level + 1, t.body), Set(t))
freevars_at(level::Int, t::DeBruijnApp) = union(freevars_at(level, t.car), freevars_at(level, t.cdr))
