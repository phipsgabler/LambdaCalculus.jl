export ≃, ≄, alpha_equivalent,
    evaluate,
    freevars,
    reify,
    substitute,
    freevartype,
    boundvartype
    

"""
    alpha_equivalent(term, term)

Determine syntactic equivalence between terms (modulo bound variables).
"""
function alpha_equivalent end

const ≃ = alpha_equivalent
const ≄ = !≃


"""
    evaluate(term) -> term

Reduce `term` to normal form
"""
function evaluate end


"""
    freevars(t::Term) -> Set

Calculate the set of free variables in `t`.
"""
function freevars end


"""
    reify(t::Term) -> Expr

Construct an expression which, when evaluated, returns `t`.
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


