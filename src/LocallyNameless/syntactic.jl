import ..LambdaCalculus: alpha_equivalent, evaluate, evaluateonce, freevars, substitute

export closeterm,
    is_lc,
    openterm


alpha_equivalent(t1::Term, t2::Term) = t1 == t2


freevars(t::FVar) = Set([t.name])
freevars(t::BVar) = Set{Symbol}()
freevars(t::Abs) = freevars(t.body)
freevars(t::App) = freevars(t.car) ∪ freevars(t.cdr)


openterm(k::Index, u::BVar, t::BVar) = t.index == k ? BVar(u.index + k - 1) : t
openterm(k::Index, u::Term, t::BVar) = t.index == k ? u : t
openterm(k::Index, u::Term, t::FVar) = t
openterm(k::Index, u::Term, t::App) = App(openterm(k, u, t.car), openterm(k, u, t.cdr))
openterm(k::Index, u::Term, t::Abs) = Abs(openterm(k + 1, u, t.body))
openterm(u::Term, t::Term) = openterm(1, u, t)


closeterm(k::Index, x::Symbol, t::BVar) = t
closeterm(k::Index, x::Symbol, t::FVar) = t.name == x ? BVar(k) : t
closeterm(k::Index, x::Symbol, t::App) = App(closeterm(k, x, t.car), closeterm(k, x, t.cdr))
closeterm(k::Index, x::Symbol, t::Abs) = Abs(closeterm(k + 1, x, t.body))
closeterm(x::Symbol, t::Term) = closeterm(1, x, t)


substitute(x::Symbol, u::Term, t::BVar) = t
substitute(x::Symbol, u::Term, t::FVar) = t.name == x ? u : t
substitute(x::Symbol, u::Term, t::App) = App(substitute(x, u, t.car), substitute(x, u, t.cdr))
substitute(x::Symbol, u::Term, t::Abs) = Abs(substitute(x, u, t.body))


is_lc(t::BVar, level::Index) = t.index ≤ level
is_lc(t::FVar, level::Index) = true
is_lc(t::App, level::Index) = is_lc(t.car, level) && is_lc(t.cdr, level)
is_lc(t::Abs, level::Index) = is_lc(t.body, level)
is_lc(t::Term) = is_lc(t, 1)


function evaluateonce_app(car::Abs, cdr::Term)
    openterm(cdr, car.body)
end

function evaluateonce_app(car::Union{App, FVar, BVar}, cdr::Term)
    newcar = evaluateonce(car)
    if newcar === nothing
        newcdr = evaluateonce(cdr)
        if newcdr === nothing
            nothing
        else
            App(car, newcdr)
        end
    else
        App(newcar, cdr)
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
