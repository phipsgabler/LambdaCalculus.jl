module Named

import Base: show, getindex

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



freevars(t::Var) = Set([t.name])
freevars(t::Abs) = filter(!isequal(t.boundname), freevars(t.body))
freevars(t::App) = freevars(t.car) ∪ freevars(t.cdr)

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
            freshvar = Var(freshname(addprime(name), fv))
            t′ = Abs(freshvar.name, substitute(name, freshvar, t.body))
            return substitute(name, s, t′)
        end
    end
end

"""
    substitute(x::Symbol, s::Term, t::Term) -> Term

Capture-avoiding substitution of `x` in `t` by `s`, commonly written like `t[x -> s]`.  Will
rename bound variables, if required.
"""
substitute


getindex(t::Term, subst::Pair{Symbol, <:Term}) = substitute(subst[1], subst[2], t)

end # module Named
