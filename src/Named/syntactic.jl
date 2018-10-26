import ..LambdaCalculus: alpha_equivalent, freevars, substitute

const EqList = Vector{Tuple{Symbol, Symbol}}

function alpha_equivalent(t1::Var, t2::Var, equivalences::EqList)
    # see: https://cs.stackexchange.com/a/76621/28930
    # Either both bindings must appear in the same spot (they were bound by the same Abs) or
    # neither appears and they are equal (they are both free and they are equal).
    
    for (x, y) in equivalences
        if x == t1.name && y == t2.name
            return true
        elseif x != t1.name && y != t2.name
            continue
        else
            return false
        end
    end

    return t1.name == t2.name
end

alpha_equivalent(t1::App, t2::App, equivalences::EqList) =
    alpha_equivalent(t1.car, t2.car, equivalences) && alpha_equivalent(t1.cdr, t2.cdr, equivalences)
alpha_equivalent(t1::Abs, t2::Abs, equivalences::EqList) =
    alpha_equivalent(t1.body, t2.body, [(t1.boundname, t2.boundname); equivalences])
alpha_equivalent(t1::Term, t2::Term, equivalences::EqList) = false
alpha_equivalent(t1::Term, t2::Term) = alpha_equivalent(t1, t2, Tuple{Symbol, Symbol}[])


freevars(t::Var) = Set([t.name])
freevars(t::Abs) = filter(!isequal(t.boundname), freevars(t.body))
freevars(t::App) = freevars(t.car) ∪ freevars(t.cdr)


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
