module Named

import Base: convert, getindex, show

using ..Lambdas

export Term,
    Var,
    App,
    Abs,
    freevars,
    substitute,
    @lambda


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
    return name == t.name ? s : t
end

function substitute(name::Symbol, s::Term, t::App)
    return App(substitute(name, s, t.car), substitute(name, s, t.cdr))
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


# Conversions from expressions to terms
convert(::Type{Var}, v::Symbol) = Var(v)
convert(::Type{Term}, v::Symbol) = convert(Var, v)

function convert(::Type{App}, expr::Expr)
    @assert(length(expr.args) >= 2, "call must contain arguments")
    mapfoldl(e -> convert(Term, e), (e, arg) -> App(e, arg), expr.args)
end

function convert(::Type{Abs}, expr::Expr)
    @assert(isa(expr.args[1], Symbol), "only single-argument lambdas are allowed")
    # TODO: handle multiple arguments
    Abs(expr.args[1], convert(Term, expr.args[2]))
end

function convert(::Type{Term}, expr::Expr)
    if expr.head == :call
        # TODO: handle :* case
        convert(App, expr)
    elseif expr.head == :->
        convert(Abs, expr)
    elseif expr.head == :$ && length(expr.args) == 1
        esc(expr.args[1])
    elseif expr.head == :block
        # Such trivial blocks are used by the parser in lambdas to add metadata.
        # They consist of a LineNumberNode followed by the actual expression.
        convert(Term, expr.args[end])
    else
        @error "unhandled syntax: $expr"
    end
end

# Conversions from terms to expressions
convert(::Type{Expr}, v::Var) = :($(v.name))
convert(::Type{Expr}, t::Abs) = :($(t.boundname) -> $(convert(Expr, t.body)))
convert(::Type{Expr}, t::App) = :(($(convert(Expr, t.car))($(convert(Expr, t.cdr)))))

reify(v::Var) = :(Var($(Meta.quot(v.name))))
reify(t::Abs) = :(Abs($(Meta.quot(t.boundname)), $(reify(t.body))))
reify(t::App) = :(App($(reify(t.car)), $(reify(t.cdr))))

"""
    reify(t::Term) -> Expr

Construct an expression which, when evaluated, returns `t`.
"""
reify


"Convert a (well-formed) Julia expression to a `Term`."
macro lambda(expr)
    return reify(convert(Term, expr))
end


end # module Named
