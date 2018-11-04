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

        # interpolation of named terms is _not_ hygienic
        t = N.@lambda x -> y
        @test (N.@lambda y -> $t) ≄ (N.@lambda z1 -> z2 -> y)
        @test (N.@lambda y -> $t) ≃ (N.@lambda z1 -> z2 -> z1)
    end

    @testset "DeBruijn" begin
        id = D.@λ x -> x
        l = D.@λ $id(a)
        r = D.@λ (y -> y)(a)
        @test l ≃ r

        @test freevars(D.@λ x -> y) == Set([1])
        @test (D.@λ [x, y] x) ≄ (D.@lambda [x, y] y)

        # interpolation of de Bruijn terms _is_ hygienic (inserted terms are shifted)
        t = D.@lambda x -> y
        @test (D.@lambda y -> $t) ≃ (D.@lambda z1 -> z2 -> y)
    end

    @testset "LocallyNameless" begin
        id = LN.@λ x -> x
        l = LN.@λ $id(a)
        r = LN.@λ (y -> y)(a)
        @test l ≃ r

        @test freevars(LN.@λ x -> y) == Set([:y])
        @test (LN.@λ x) ≄ (LN.@lambda y)

        # interpolation of locally nameless terms _is_ hygienic (inserted terms are shifted)
        t = LN.@lambda x -> y
        @test (LN.@lambda y -> $t) ≃ (LN.@lambda z1 -> z2 -> y)
    end
end

@testset "Conversion" begin
    Γ = NamingContext([:x, :y, :z])
    
    named_lambdas = [(N.@lambda x -> x),
                     (N.@lambda (x -> x(x))(x -> x(x))),
                     (N.@lambda x -> y -> x),
                     (N.@lambda x -> y)]

    debruijn_lambdas = [(D.@lambda x -> x),
                        (D.@lambda (x -> x(x))(x -> x(x))),
                        (D.@lambda x -> y -> x),
                        (D.@lambda [x, y, z] x -> y)]

    ln_lambdas = [(LN.@lambda x -> x),
                  (LN.@lambda (x -> x(x))(x -> x(x))),
                  (LN.@lambda x -> y -> x),
                  (LN.@lambda x -> y)]

    # this used to cause a shadowing problem:
    @test convert(D.Term, N.@lambda((x -> (x -> x)))) ≃ D.@lambda x -> (y -> y)

    # conversion back to self
    for t in named_lambdas
        @test convert(N.Term, convert(D.Term, t, Γ), Γ) ≃ t
        @test convert(N.Term, convert(LN.Term, t, Γ), Γ) ≃ t
    end

    for t in debruijn_lambdas
        @test convert(D.Term, convert(N.Term, t, Γ), Γ) ≃ t
        @test convert(D.Term, convert(LN.Term, t, Γ), Γ) ≃ t
    end

    for t in ln_lambdas
        @test convert(LN.Term, convert(D.Term, t, Γ), Γ) ≃ t
        @test convert(LN.Term, convert(N.Term, t, Γ), Γ) ≃ t
    end

    # conversion to other formats
    for (tn, td, tl) in zip(named_lambdas, debruijn_lambdas, ln_lambdas)
        @test convert(D.Term, tn, Γ) ≃ td
        @test convert(LN.Term, tn, Γ) ≃ tl
        
        @test convert(N.Term, td, Γ) ≃ tn
        @test convert(LN.Term, td, Γ) ≃ tl

        @test convert(N.Term, tl, Γ) ≃ tn
        @test convert(D.Term, tl, Γ) ≃ td
    end
end

@testset "Evaluation" begin
    @testset "DeBruijn" begin
        terms = [D.@lambda((x -> (x -> x))(z -> z)),
                 D.@lambda((x -> x)(z -> (x -> x)(z))),
                 D.@lambda(y -> (f -> x -> f(x))(y)),
                 D.@lambda((f -> x -> f(x))(f -> x -> f(x))),
                 D.@lambda((f -> x -> f(f(x)))(f -> x -> f(f(x)))),
                 D.@lambda((x -> x)(y))]
        results = [D.@lambda(x -> x),
                   D.@lambda(z -> z),
                   D.@lambda(f -> x -> f(x)),
                   D.@lambda(f -> x -> f(x)),
                   D.@lambda(x -> y -> x(x(x(x(y))))),
                   D.@lambda(y)]
        
        for (t, r) in zip(terms, results)
            @test evaluate(t, 100) ≃ r
        end
    end

    @testset "LocallyNameless" begin
        terms = [LN.@lambda((x -> (x -> x))(z -> z)),
                 LN.@lambda((x -> x)(z -> (x -> x)(z))),
                 LN.@lambda(y -> (f -> x -> f(x))(y)),
                 LN.@lambda((f -> x -> f(x))(f -> x -> f(x))),
                 LN.@lambda((f -> x -> f(f(x)))(f -> x -> f(f(x)))),
                 LN.@lambda((x -> x)(y))]
        results = [LN.@lambda(x -> x),
                   LN.@lambda(z -> z),
                   LN.@lambda(f -> x -> f(x)),
                   LN.@lambda(f -> x -> f(x)),
                   LN.@lambda(x -> y -> x(x(x(x(y))))),
                   LN.@lambda(y)]
        
        for (t, r) in zip(terms, results)
            @test evaluate(t, 100) ≃ r
        end
    end
end

@testset "Sampling" begin
    for t in rand(D.BoundedTermSampler(20, 30), 100)
        @test 20 ≤ length(t) ≤ 30
    end
end


