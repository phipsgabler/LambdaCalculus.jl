import ..LambdaCalculus.LocallyNameless

export @lambda, @λ

function meta_convert(expr::Expr, Γ::NamingContext)
    if expr.head == :call && length(expr.args) ≥ 1
        # TODO: handle :* case
        mapfoldl(e -> meta_convert(e, Γ), (e, arg) -> :(App($e, $arg)), expr.args)
    elseif expr.head == :->
        boundname = expr.args[1]
        body = meta_convert(expr.args[2], pushfirst(Γ, boundname))
        :(Abs($body))
    elseif expr.head == :$ && length(expr.args) == 1
        esc(expr.args[1])
    elseif expr.head == :block
        # Such trivial blocks are used by the parser in lambdas to add metadata.
        # They consist of an optional LineNumberNode followed by the actual expression.
        meta_convert(expr.args[end], Γ)
    else
        error("unhandled syntax: $expr")
    end
end

function meta_convert(name::Symbol, Γ::NamingContext)
    index = findfirst(isequal(name), Γ)
    if index === nothing
        :(FVar($(Meta.quot(name))))
    else
        :(BVar($index))
    end
end

meta_convert(other, Γ::NamingContext) = error("unhandled literal: $other")


"Convert a (well-formed) Julia expression to a `Term`."
macro lambda(expr)
    meta_convert(expr, NamingContext())
end

"Convert a (well-formed) Julia expression to a `Term`."
macro λ(expr)
    meta_convert(expr, NamingContext())
end
