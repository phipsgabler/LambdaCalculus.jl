import .Named
import .DeBruijn

# prevent warning, instance of https://github.com/JuliaLang/julia/issues/29059
__precompile__(false)


@eval Named begin
    macroconvert(name::Symbol) = :(Var($(Meta.quot(name))))
    
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
            @error "unhandled syntax: $expr"
        end
    end

    
    "Convert a (well-formed) Julia expression to a `Term`."
    macro lambda(expr)
        macroconvert(expr)
    end

    "Convert a (well-formed) Julia expression to a `Term`."
    macro λ(expr)
        return macroconvert(expr)
    end

    export @lambda, @λ
end


@eval DeBruijn begin
    import ..Lambdas.Named
    
    "Convert a (well-formed) Julia expression to a `Term`."
    macro lambda(expr)
        return :(convert(Term, Named.@lambda($expr)))
    end

    "Convert a (well-formed) Julia expression to a `Term`."
    macro λ(expr)
        return :(@lambda $expr)
    end

    export @lambda, @λ
end
