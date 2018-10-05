import .Named
import .DeBruijn

export alpha_equivalent,
    ≃

alpha_equivalent(t1::DeBruijn.Term, t2::DeBruijn.Term) = t1 == t2
alpha_equivalent(t1::Named.Term, t2::Named.Term) = alpha_equivalent(convert(DeBruijn.Term, t1),
                                                                    convert(DeBruijn.Term, t2))

const ≃ = alpha_equivalent
