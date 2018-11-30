using MacroTools
import ..LambdaCalculus.Named

export @lambda, @λ


function meta_freevars(expr)
    if isexpr(expr, :$)
        @assert length(expr.args) == 1
        return Set{Symbol}()
    end
    
    @match expr begin
        (f_(arg1_, args__)) => mapreduce(meta_freevars, ∪, [f, arg1, args...])
        (arg_Symbol -> body_) => filter(!isequal(arg), meta_freevars(body))
        (name_Symbol) => Set([name])
        other_ => error("unhandled expression: $other")
    end
end


function meta_convert1(expr, Γ::NamingContext, level::Int = 0)
    if isexpr(expr, :$)
        @assert length(expr.args) == 1
        return :(shift($level, $(esc(expr.args[1]))))
    end
    
    @match expr begin
        (f_(arg1_, args__)) => mapfoldl(e -> meta_convert1(e, Γ, level),
                                        (e, arg) -> :(App($e, $arg)),
                                        [f, arg1, args...])
        (arg_Symbol -> body_) => :(Abs($(meta_convert1(body, pushfirst(Γ, arg), level + 1))))
        (name_Symbol) => :(Var($(findfirst(isequal(name), Γ))))
        other_ => error("unhandled expression: $other")
    end
end


function meta_convert(expr)
    expr = MacroTools.prewalk(unblock ∘ rmlines, expr)
    meta_convert1(expr, NamingContext(meta_freevars(expr)))
end

function meta_convert(expr, Γ::NamingContext)
    expr = MacroTools.prewalk(unblock ∘ rmlines, expr)
    meta_convert1(expr, Γ)
end


"Convert a (well-formed) Julia expression to a `Term`."
macro lambda(expr)
    meta_convert(expr)
end

macro lambda(Γ, expr)
    if Γ.head == :vect
        meta_convert(expr, NamingContext(collect(Symbol, Γ.args)))
    else
        error("invalid context specification: $Γ")
    end
end

"Convert a (well-formed) Julia expression to a `Term`."
macro λ(expr)
    meta_convert(expr)
end

macro λ(Γ, expr)
    if Γ.head == :vect
        meta_convert(expr, NamingContext(collect(Symbol, Γ.args)))
    else
        error("invalid context specification: $Γ")
    end
end
