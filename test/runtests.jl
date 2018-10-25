using LambdaCalculus
using Test


const N = LambdaCalculus.Named
const D = LambdaCalculus.DeBruijn
const Log = Base.CoreLogging

Log.global_logger(Log.SimpleLogger(stderr, Log.Debug))


# MACROS
@testset "Macros" begin
    @testset "Named" begin
        id = N.@λ x -> x
        l = N.@λ $id(a)
        r = N.@λ (y -> y)(a)
        @test l ≃ r

        @test freevars(N.@λ x -> y) == Set([:y])
        @test (N.@λ x) ≄ (N.@lambda y)
    end

    @testset "DeBruijn" begin
        id = D.@λ x -> x
        @test_skip l = D.@λ $id(a)
        l = D.@lambda (x -> x)(a)
        r = D.@λ (y -> y)(a)
        @test l ≃ r

        @test freevars(D.@λ x -> y) == Set([2])
        @test_skip (D.@λ x) ≄ (D.@lambda y)
    end
end

@testset "Conversion" begin
    varnames = [:x, :y, :z]
    
    named_lambdas = [(N.@lambda x -> x),
                     (N.@lambda (x -> x(x))(x -> x(x))),
                     (N.@lambda x -> y -> x),
                     (N.@lambda x -> y)]

    debruijn_lambdas = [(D.@lambda x -> x),
                        (D.@lambda (x -> x(x))(x -> x(x))),
                        (D.@lambda x -> y -> x),
                        (D.@lambda x -> y)]

    @test convert(D.Term, N.@lambda((x -> (x -> x)))) ≃ D.@lambda x -> (y -> y)
    
    for t in named_lambdas
        @test_skip convert(N.Term, convert(D.Term, t), varnames) ≃ t
    end

    for t in debruijn_lambdas
        @test convert(D.Term, convert(N.Term, t, [:x, :y, :z])) == t
    end

    for (tn, tx) in zip(named_lambdas, debruijn_lambdas)
        @test convert(D.Term, tn) == tx
        @test_skip convert(N.Term, tx, varnames) ≃ tn
    end
end

@testset "Evaluation" begin
    @testset "DeBruijn" begin
        terms = [D.@lambda((x -> (x -> x))(z -> z)),
                 D.@lambda((x -> x)(z -> (x -> x)(z))),
                 D.@lambda((f -> x -> f(f(x)))(f -> x -> f(f(x))))]
        results = [D.@lambda(x -> x),
                   D.@lambda(z -> z),
                   D.@lambda(x -> y -> x(x(x(x(y)))))]
        
        for (t, r) in zip(terms, results)
            @test D.evaluate(t, 100) ≃ r
        end
    end
end

