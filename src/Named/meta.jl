using MacroTools

export @lambda, @λ


function meta_convert1(expr)
    if isexpr(expr, :$)
        @assert length(expr.args) == 1
        return esc(expr.args[1])
    end
    
    @match expr begin
        (f_(arg1_, args__)) => mapfoldl(e -> meta_convert1(e),
                                        (e, arg) -> :(App($e, $arg)),
                                        [f, arg1, args...])
        (arg_Symbol -> body_) => :(Abs($(Meta.quot(arg)), $(meta_convert1(body))))
        (name_Symbol) => :(Var($(Meta.quot(name))))
        other_ => error("unhandled expression: $other")
    end
end

meta_convert(expr) = meta_convert1(MacroTools.prewalk(unblock ∘ rmlines, expr))


"Convert a (well-formed) Julia expression to a `Term`."
macro lambda(expr)
    meta_convert(expr)
end

"Convert a (well-formed) Julia expression to a `Term`."
macro λ(expr)
    meta_convert(expr)
end
