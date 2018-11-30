using MacroTools
import ..LambdaCalculus.LocallyNameless

export @lambda, @λ


function meta_convert1(expr, Γ::NamingContext)
    if isexpr(expr, :$)
        @assert length(expr.args) == 1
        return esc(expr.args[1])
    end
    
    @match expr begin
        (f_(arg1_, args__)) => mapfoldl(e -> meta_convert1(e, Γ),
                                        (e, arg) -> :(App($e, $arg)),
                                        [f, arg1, args...])
        (arg_Symbol -> body_) => :(Abs($(meta_convert1(body, pushfirst(Γ, arg)))))
        (name_Symbol) => begin
            index = findfirst(isequal(name), Γ)
            if index === nothing
                :(FVar($(Meta.quot(name))))
            else
                :(BVar($index))
            end
        end
        other_ => error("unhandled expression: $other")
    end
end

meta_convert(expr, Γ::NamingContext) = meta_convert1(MacroTools.prewalk(unblock ∘ rmlines, expr), Γ)


"Convert a (well-formed) Julia expression to a `Term`."
macro lambda(expr)
    meta_convert(expr, NamingContext())
end

"Convert a (well-formed) Julia expression to a `Term`."
macro λ(expr)
    meta_convert(expr, NamingContext())
end
