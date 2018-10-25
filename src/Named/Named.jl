module Named

using Reexport
@reexport using ..LambdaCalculus

import Base: convert, show
import ..LambdaCalculus: boundvartype, freevartype, reify


export Term,
    Var,
    App,
    Abs


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


show(io::IO, t::Abs) = print(io, "(λ", t.boundname, ".", t.body, ")")
show(io::IO, t::App) =  print(io, "(", t.car, " ", t.cdr, ")")
show(io::IO, t::Var) = print(io, t.name)


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

freevartype(::Type{<:Term}) = Var
boundvartype(::Type{<:Term}) = Var


include("syntactic.jl")
include("meta.jl")

end # module Named
