import ..LambdaCalculus: ≃, alpha_equivalent, evaluate, evaluateonce, freevars, substitute

export evaluateonce,
    shift

alpha_equivalent(t1::Term, t2::Term) = t1 == t2


freevars(t::Term) = freevars_at(0, t)
freevars_at(level::Int, t::Var) = t.index > level ? Set([t.index]) : Set{Index}()
freevars_at(level::Int, t::Abs) = setdiff(freevars_at(level + 1, t.body), Set([t]))
freevars_at(level::Int, t::App) = freevars_at(level, t.car) ∪ freevars_at(level, t.cdr)


shift(c::Index, d::Index, t::Var) = (t.index < c) ? t : Var(t.index + d)
shift(c::Index, d::Index, t::Abs) = Abs(shift(c + 1, d, t.body))
shift(c::Index, d::Index, t::App) = App(shift(c, d, t.car), shift(c, d, t.cdr))

"""
    shift(c, d, term) -> Term
Increase indices of free variables in `term`, which are at least as big as `c`, by `d`.
"""
shift

"""
    shift(d, term) -> Term
Increase indices of free variables in `term` by `d`.
"""
shift(d::Index, t::Term) = shift(1, d, t)


substitute(i::Index, s::Term, t::Var) = (t.index == i) ? s : t
substitute(i::Index, s::Term, t::App) = App(substitute(i, s, t.car), substitute(i, s, t.cdr))
substitute(i::Index, s::Term, t::Abs) = Abs(substitute(i + 1, shift(1, s), t.body))


function evaluateonce_app(car::Abs, cdr::Term)
    shift(-1, substitute(1, shift(1, cdr), car.body))
end

function evaluateonce_app(car::Union{App, Var}, cdr::Term)
    newcar = evaluateonce(car)
    if newcar === nothing
        newcdr = evaluateonce(cdr)
        if newcdr !== nothing
            App(car, newcdr)
        else
            nothing
        end
    else
        App(newcar, cdr)
    end
end


evaluateonce(term::Var) = nothing
evaluateonce(term::App) = evaluateonce_app(term.car, term.cdr)
function evaluateonce(term::Abs)
    newbody = evaluateonce(term.body)
    if newbody !== nothing
        Abs(newbody)
    else
        nothing
    end
end


function evaluate(term::Term, maxsteps = Inf)
    while maxsteps > 0
        reduced = evaluateonce(term)

        if reduced === nothing
            return term
        else
            term = reduced
            maxsteps -= 1
        end
    end

    return term
end
