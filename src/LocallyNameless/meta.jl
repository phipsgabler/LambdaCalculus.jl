import ..LambdaCalculus.LocallyNameless

export @lambda, @λ

function meta_convert(expr::Expr, bv = Symbol[])
    if expr.head == :call && length(expr.args) ≥ 1
        # TODO: handle :* case
        mapfoldl(e -> meta_convert(e, bv), (e, arg) -> :(App($e, $arg)), expr.args)
    elseif expr.head == :->
        boundname = expr.args[1]
        body = meta_convert(expr.args[2], [boundname; bv])
        :(Abs($body))
    elseif expr.head == :$ && length(expr.args) == 1
        esc(expr.args[1])
    elseif expr.head == :block
        # Such trivial blocks are used by the parser in lambdas to add metadata.
        # They consist of an optional LineNumberNode followed by the actual expression.
        meta_convert(expr.args[end], bv)
    else
        error("unhandled syntax: $expr")
    end
end

function meta_convert(name::Symbol, bv = Symbol[])
    index = findfirst(isequal(name), bv)
    if index === nothing
        :(FVar($(Meta.quot(name))))
    else
        :(BVar($index))
    end
end

meta_convert(other, bv = Symbol[]) = error("unhandled literal: $other")


"Convert a (well-formed) Julia expression to a `Term`."
macro lambda(expr)
    meta_convert(expr)
end

"Convert a (well-formed) Julia expression to a `Term`."
macro λ(expr)
    meta_convert(expr)
end
