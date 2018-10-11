using Lambdas
using Test


const N = Lambdas.Named
const D = Lambdas.DeBruijn
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
