import ..LambdaCalculus: freevars, substitute

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
