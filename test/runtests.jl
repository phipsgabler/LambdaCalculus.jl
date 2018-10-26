using LambdaCalculus
using Test


const N = LambdaCalculus.Named
const D = LambdaCalculus.DeBruijn
const LN = LambdaCalculus.LocallyNameless

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

        t = N.@lambda x -> y
        @test_broken (N.@lambda y -> $t) ≃ (N.@lambda z1 -> z2 -> y)
    end

    @testset "DeBruijn" begin
        id = D.@λ x -> x
        l = D.@λ $id(a)
        r = D.@λ (y -> y)(a)
        @test l ≃ r

        @test freevars(D.@λ x -> y) == Set([2])
        @test_broken (D.@λ x) ≄ (D.@lambda y)

        t = D.@lambda x -> y
        @test (D.@lambda y -> $t) ≃ (D.@lambda z1 -> z2 -> y)
    end

    @testset "LocallyNameless" begin
        id = LN.@λ x -> x
        l = LN.@λ $id(a)
        r = LN.@λ (y -> y)(a)
        @test l ≃ r

        @test freevars(LN.@λ x -> y) == Set([:y])
        # @test_broken (LN.@λ x) ≄ (LN.@lambda y)

        t = LN.@lambda x -> y
        @test (LN.@lambda y -> $t) ≃ (LN.@lambda z1 -> z2 -> y)
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
            @test evaluate(t, 100) ≃ r
        end
    end
end

