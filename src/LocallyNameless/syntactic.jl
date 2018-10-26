import ..LambdaCalculus: alpha_equivalent, evaluate, evaluateonce, freevars, substitute

export closeterm,
    is_lc,
    openterm


alpha_equivalent(t1::Term, t2::Term) = t1 == t2


freevars(t::FVar) = Set([t.name])
freevars(t::BVar) = Set{Symbol}()
freevars(t::Abs) = freevars(t.body)
freevars(t::App) = freevars(t.car) ∪ freevars(t.cdr)


openterm(i::Index, s::Term, t::BVar) = t.index == i ? s : t
openterm(i::Index, s::Term, t::FVar) = t
openterm(i::Index, s::Term, t::App) = App(openterm(i, s, t.car), openterm(i, s, t.cdr))
openterm(i::Index, s::Term, t::Abs) = Abs(t.boundname, openterm(i + 1, s, t.body))
openterm(s::Term, t::Term) = openterm(1, s, t)


closeterm(i::Index, x::Symbol, t::BVar) = t
closeterm(i::Index, x::Symbol, t::FVar) = t.index == i ? BVar(i) : t
closeterm(i::Index, x::Symbol, t::App) = App(closeterm(i, x, t.car), closeterm(i, x, t.cdr))
closeterm(i::Index, x::Symbol, t::Abs) = Abs(t.boundname, closeterm(i + 1, x, t.body))
closeterm(x::Symbol, t::Term) = closeterm(1, x, t)


substitute(x::Symbol, s::Term, t::BVar) = t
substitute(x::Symbol, s::Term, t::FVar) = t.name == x ? s : t
substitute(x::Symbol, s::Term, t::App) = App(substitute(x, s, t.car), substitute(x, s, t.cdr))
substitute(x::Symbol, s::Term, t::Abs) = Abs(t.boundname, substitute(x, s, t.body))


is_lc(t::BVar, level::Index) = t.index ≤ level
is_lc(t::FVar, level::Index) = true
is_lc(t::App, level::Index) = is_lc(t.car, level) && is_lc(t.cdr, level)
is_lc(t::Abs, level::Index) = is_lc(t.body, level)
is_lc(t::Term) = is_lc(t, 1)


function evaluateonce_app(car::Abs, cdr::Term)
    openterm(1, cdr, car.body)
end

function evaluateonce_app(car::Union{App, FVar, BVar}, cdr::Term)
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


function evaluateonce_app(car::App, cdr::Term)
    newcar = evaluateonce(car)
    if newcar !== nothing
        App(newcar, cdr)
    else
        nothing
    end
end

evaluateonce(term::Union{FVar, BVar}) = nothing
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
