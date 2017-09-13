import Base: show

abstract type NamedTerm <: LambdaTerm end

struct NamedVar <: NamedTerm
    name::Symbol
end

struct NamedAbs <: NamedTerm
    boundname::Symbol
    body::NamedTerm
end

struct NamedApp <: NamedTerm
    car::NamedTerm
    cdr::NamedTerm
end


function Base.show(io::IO, t::DeBruijnAbs)
    print(io, "(λ", t.boundname, ".", t.body, ")")
end

function Base.show(io::IO, t::DeBruijnApp)
    print(io, "(", t.car, " ", t.cdr, ")")
end

function Base.show(io::IO, t::DeBruijnVar)
    print(io, t.name)
end


freevars(t::NamedVar) = Set(t)
freevars(t::NamedAbs) = setdiff(freevars(t.body), Set(t))
freevars(t::NamedApp) = union(freevars(t.car), freevars(t.cdr))
