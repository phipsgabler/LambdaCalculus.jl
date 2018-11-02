export ≃, ≄,
    alpha_equivalent,
    evaluate,
    evaluateonce,
    freevars,
    reify,
    substitute,
    freevartype,
    boundvartype
    

export AbstractTerm,
    Index,
    Name


abstract type AbstractTerm end

const Index = Int
const Name = Symbol

"""
    alpha_equivalent(term, term)

Determine syntactic equivalence between terms (modulo bound variables).
"""
function alpha_equivalent end

const ≃ = alpha_equivalent
const ≄ = !≃


"""
    evaluate(term[, maxsteps])

Evaluate `term` in normal order, using maximally `maxsteps` reductions.
"""
function evaluate end


"""
    evaluateonce(term)

Evaluate `term` by one step in normal order (i.e., the leftmost, outermost redex).  If there
is no redex, return `nothing`.
"""
function evaluateonce end


"""
    freevars(term) -> Set

Calculate the set of free variables in `term`.
"""
function freevars end


"""
    reify(term) -> Expr

Construct an expression which, when evaluated, returns `term`.
"""
function reify end


"""
    substitute(v, s::Term, t::Term) -> Term

Capture-avoiding substitution of variable `v` in `t` by `s`, commonly written like `t[v -> s]`.
Will rename bound variables, if required.
"""
function substitute end


"""
    freevartype(type) -> Type

Determine the type of free variables used in term type `type`.
"""
function freevartype end

freevartype(t::T) where {T} = freevartype(T)


"""
    boundvartype(type) -> Type

Determine the type of bound variables used in term type `type`.
"""
function boundvartype end

boundvartype(t::T) where {T} = boundvartype(T)


