using Lambdas
using Test



# MACROS
for ns in [:(Lambdas.Named), :(Lambdas.DeBruijn)]
    @eval begin
        id = $ns.@λ x -> x

        @test ($ns.@λ (y -> y)(a)) ≃ ($ns.@λ (x -> x)(a))

        
        # @test alpha_equivalent(id_xx, id_x_result)
        # @test alpha_equivalent(id_xn, id_x_result)
        # @test alpha_equivalent(id_nn, id_n_result)
        # @test alpha_equivalent(id_nx, id_n_result)

        # t = @evaluate x -> (x -> x)(y)
        # t_result = @lambda x -> y
        # @test alpha_equivalent(t, t_result)
    end
end
