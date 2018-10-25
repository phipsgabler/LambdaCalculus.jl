import ..LambdaCalculus.Named

export @lambda, @λ

function meta_freevars(expr::Expr)
    if expr.head == :call
        mapreduce(meta_freevars, ∪, expr.args)
    elseif expr.head == :->
        boundname = expr.args[1]
        filter(!isequal(boundname), meta_freevars(expr.args[2]))
    elseif expr.head == :$ && length(expr.args) == 1
        Set{Symbol}()
    elseif expr.head == :block
        meta_freevars(expr.args[end])
    else
        error("unhandled syntax: $expr")
    end
end

meta_freevars(name::Symbol) = Set([name])
meta_freevars(other) = error("unhandled literal: $other")


function meta_convert(expr::Expr, fv::Vector{Symbol}, level = 0)
    if expr.head == :call && length(expr.args) ≥ 1
        # TODO: handle :* case
        mapfoldl(e -> meta_convert(e, fv, level), (e, arg) -> :(App($e, $arg)), expr.args)
    elseif expr.head == :->
        boundname = expr.args[1]
        body = meta_convert(expr.args[2], [boundname; fv], level + 1)
        :(Abs($body))
    elseif expr.head == :$ && length(expr.args) == 1
        :(shift($level, $(esc(expr.args[1]))))
    elseif expr.head == :block
        # Such trivial blocks are used by the parser in lambdas to add metadata.
        # They consist of an optional LineNumberNode followed by the actual expression.
        meta_convert(expr.args[end], fv, level)
    else
        error("unhandled syntax: $expr")
    end
end

meta_convert(name::Symbol, fv::Vector{Symbol}, level = 0) = :(Var($(findfirst(isequal(name), fv))))
meta_convert(other, fv::Vector{Symbol}, level = 0) = error("unhandled literal: $other")


"Convert a (well-formed) Julia expression to a `Term`."
macro lambda(expr)
    meta_convert(expr, collect(meta_freevars(expr)))
end

"Convert a (well-formed) Julia expression to a `Term`."
macro λ(expr)
    meta_convert(expr, collect(meta_freevars(expr)))
end
