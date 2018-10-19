import ..LambdaCalculus.Named

export @lambda, @λ

"Convert a (well-formed) Julia expression to a `Term`."
macro lambda(expr)
    :(convert(Term, Named.@lambda($expr)))
end

"Convert a (well-formed) Julia expression to a `Term`."
macro λ(expr)
    :(convert(Term, Named.@lambda($expr)))
end
