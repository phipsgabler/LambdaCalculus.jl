export @lambda, @λ

function meta_convert(expr::Expr)
    if expr.head == :call
        # TODO: handle :* case
        mapfoldl(e -> meta_convert(e), (e, arg) -> :(App($e, $arg)), expr.args)
    elseif expr.head == :->
        boundname = Meta.quot(expr.args[1])
        body = meta_convert(expr.args[2])
        :(Abs($boundname, $body))
    elseif expr.head == :$ && length(expr.args) == 1
        esc(expr.args[1])
    elseif expr.head == :block
        # Such trivial blocks are used by the parser in lambdas to add metadata.
        # They consist of a LineNumberNode followed by the actual expression.
        meta_convert(expr.args[end])
    else
        error("unhandled syntax: $expr")
    end
end

meta_convert(name::Symbol) = :(Var($(Meta.quot(name))))
meta_convert(other) = error("unhandled literal: $other")


"Convert a (well-formed) Julia expression to a `Term`."
macro lambda(expr)
    meta_convert(expr)
end

"Convert a (well-formed) Julia expression to a `Term`."
macro λ(expr)
    meta_convert(expr)
end
