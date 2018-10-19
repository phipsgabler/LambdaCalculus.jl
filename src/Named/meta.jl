export @lambda, @λ

function macroconvert(expr::Expr)
    if expr.head == :call
        # TODO: handle :* case
        mapfoldl(e -> macroconvert(e), (e, arg) -> :(App($e, $arg)), expr.args)
    elseif expr.head == :->
        boundname = Meta.quot(expr.args[1])
        body = macroconvert(expr.args[2])
        :(Abs($boundname, $body))
    elseif expr.head == :$ && length(expr.args) == 1
        esc(expr.args[1])
    elseif expr.head == :block
        # Such trivial blocks are used by the parser in lambdas to add metadata.
        # They consist of a LineNumberNode followed by the actual expression.
        macroconvert(expr.args[end])
    else
        error("unhandled syntax: $expr")
    end
end

macroconvert(name::Symbol) = :(Var($(Meta.quot(name))))
macroconvert(other) = error("unhandled literal: $other")


"Convert a (well-formed) Julia expression to a `Term`."
macro lambda(expr)
    macroconvert(expr)
end

"Convert a (well-formed) Julia expression to a `Term`."
macro λ(expr)
    macroconvert(expr)
end
