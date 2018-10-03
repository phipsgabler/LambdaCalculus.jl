module Named

import Base: show

using ..Lambdas

export Term,
    Var,
    App,
    Abs,
    freevars,
    substitute


"""Named lambda terms, built using only the following rule: 

    <Term> := <Name>              (variable)
            | λ <Name> . <Term>   (abstraction)
            | (<Term> <Term>)     (application)

"""
abstract type Term <: AbstractTerm end

struct Var <: Term
    name::Symbol
end

struct Abs <: Term
    boundname::Symbol
    body::Term
end

struct App <: Term
    car::Term
    cdr::Term
end


function show(io::IO, t::Abs)
    print(io, "(λ", t.boundname, ".", t.body, ")")
end

function show(io::IO, t::App)
    print(io, "(", t.car, " ", t.cdr, ")")
end

function show(io::IO, t::Var)
    print(io, t.name)
end



freevars(t::Var) = Set([t])
freevars(t::Abs) = Set(v for v in freevars(t.body) if v.name != t.boundname)
freevars(t::App) = union(freevars(t.car), freevars(t.cdr))

"""
    freevars(t::Term) -> Set

Calculate the set of free variables in `t`.
"""
freevars



function substitute(name::Symbol, s::Term, t::Var)
    if name == t.name
        return s
    else
        return t
    end
end

function substitute(name::Symbol, s::Term, t::App)
    return App(substitute(name, s, t.car),
               substitute(name, s, t.cdr))
end

function substitute(name::Symbol, s::Term, t::Abs)
    if name == t.boundname
        return t
    else
        fv = freevars(t.body)
        
        if name ∉ fv
            return Abs(t.boundname, substitute(name, s, t.body))
        else
            freshname = name * "′"
            while freshname ∈ fv
                freshname *= "′"
            end

            renamed_body = substitute(name, Var(freshname), t.body)
            return Abs(t.boundname, renamed_body)
        end
    end
end


"""
    substitute(x::Symbol, s::Term, t::Term) -> Term

Capture-avoiding substitution of `x` in `t` by `s`, commonly written like `t[x -> s]`.  Will
generate fresh names in `s`, if required.
"""
substitute

end # Named
