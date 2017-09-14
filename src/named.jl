import Base: show

export NamedTerm,
    NamedVar,
    NamedApp,
    NamedAbs,
    freevars,
    substitute

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


function Base.show(io::IO, t::NamedAbs)
    print(io, "(λ", t.boundname, ".", t.body, ")")
end

function Base.show(io::IO, t::NamedApp)
    print(io, "(", t.car, " ", t.cdr, ")")
end

function Base.show(io::IO, t::NamedVar)
    print(io, t.name)
end


freevars(t::NamedVar) = Set([t])
freevars(t::NamedAbs) = Set(v for v in freevars(t.body) if v.name != t.boundname)
freevars(t::NamedApp) = union(freevars(t.car), freevars(t.cdr))


function substitute(name::Symbol, s::NamedTerm, t::NamedVar)
    if name == t.name
        return s
    else
        return t
    end
end

function substitute(name::Symbol, s::NamedTerm, t::NamedApp)
    return NamedApp(substitute(name, s, t.car),
                    substitute(name, s, t.cdr))
end

function substitute(name::Symbol, s::NamedTerm, t::NamedAbs)
    if name == t.boundname
        return t
    else
        fv = freevars(t.body)
        
        if name ∉ fv
            return NamedAbs(t.boundname, substitute(name, s, t.body))
        else
            freshname = name * "'"
            while freshname ∈ fv
                freshname *= "'"
            end

            renamed_body = substitute(name, NamedVar(freshname), t.body)
            return NamedAbs(t.boundname, renamed_body)
        end
    end
end

