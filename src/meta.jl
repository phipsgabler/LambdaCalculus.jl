import .Named
import .DeBruijn


@eval Named begin
    "Convert a (well-formed) Julia expression to a `Term`."
    macro lambda(expr)
        return reify(convert(Term, expr))
    end

    "Convert a (well-formed) Julia expression to a `Term`."
    macro λ(expr)
        return :(@lambda $expr)
    end

    export @lambda, @λ
end


@eval DeBruijn begin
    import ..Lambdas.Named
    
    "Convert a (well-formed) Julia expression to a `Term`."
    macro lambda(expr)
        return reify(convert(Term, convert(Named.Term, expr)))
    end

    "Convert a (well-formed) Julia expression to a `Term`."
    macro λ(expr)
        return :(@lambda $expr)
    end

    export @lambda, @λ
end
