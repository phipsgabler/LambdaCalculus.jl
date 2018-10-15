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
    end

    @testset "DeBruijn" begin
        id = D.@λ x -> x
        l = D.@λ (x -> x)(a)
        r = D.@λ (y -> y)(a)
        @test l ≃ r

        @test freevars(D.@λ x -> y) == Set([2])
        @test (D.@λ x) ≃ (D.@lambda y)
    end
    
    # testcode = @rawquote begin
    #     id = @λ x -> x
    #     l = @λ $id(a)
    #     r = @λ (y -> y)(a)
    #     @test l ≃ r

        
    #     # @test alpha_equivalent(id_xx, id_x_result)
    #     # @test alpha_equivalent(id_xn, id_x_result)
    #     # @test alpha_equivalent(id_nn, id_n_result)
    #     # @test alpha_equivalent(id_nx, id_n_result)

    #     # t = @evaluate x -> (x -> x)(y)
    #     # t_result = @lambda x -> y
    # end
    
    # for ns in [:(Lambdas.Named), :(Lambdas.DeBruijn)]
    #     code = quote
    #         using $ns
    #         $testcode
    #     end

    # end
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
    
    for t in named_lambdas
        @test convert(N.Term, convert(D.Term, t), varnames) ≃ t
        # @test convert(N.Term, convert(D.Term, t), [:x, :y, :z]) == t
    end

    for t in debruijn_lambdas
        @test convert(D.Term, convert(N.Term, t, varnames)) ≃ t
        # @test convert(D.Term, convert(N.Term, t, [:x, :y, :z])) == t
    end

    # for (tn, tx) in zip(named_lambdas, debruijn_lambdas)
    #     @test convert(D.Term, tn) ≃ tx
    #     @test convert(N.Term, tx, varnames) ≃ tn
    # end
end

