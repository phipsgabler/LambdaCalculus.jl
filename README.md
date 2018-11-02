# LambdaCalculus

[![Build Status](https://travis-ci.org/phipsgabler/LambdaCalculus.jl.svg?branch=master)](https://travis-ci.org/phipsgabler/LambdasCalculus.jl)


## Representations ##

There are three different representations of lambda terms this package provides:

- Named (the standard form): e.g., (λx.x)(y).
- [De Bruijn indices](https://en.wikipedia.org/wiki/De_Bruijn_index): using numbers for bound
  variables, which refer to the enclosing binder, and as unique names for free variables,
  e.g. (λ.1)(1).
- [Locally nameless](http://www.chargueraud.org/research/2009/ln/main.pdf): a mixture of both, using
  names for free variables and indices for bound ones, e.g., (λ.1)(y).

To simplfy namespacing, each representation has its own submodule: `LambdaCalculus.Named`,
`LambdaCalculus.DeBruijn`, and `LambdaCalculus.LocallyNameless`.  All of the data structures are
instances of `LambdaCalculus.AbstractTerm`.

Common functions, such as `alpha_equivalent`, `evaluate`, `freevars`, or `substitute` are exported
from `LambdaCalculus` and reexported by the submodules.

For visual distiction, `show` uses some “exotic” parenthesizing: variables in named terms are
printed as is; de Bruijn indices are printed in ⟨angle brackets⟩; and in locally nameless terms,
indices are shown in ⌈ceiling brackets⌉, while free names are shown in ⌊floor brackets⌋:

```
((λx.x) y)
((λ.⟨1⟩) ⟨1⟩)
((λ.⌈1⌉) ⌊y⌋)
```

When working with more than one representation all the time, it might be useful to use abbreviations
for the namespaces:

```Julia
const LN = LambdaCalculus.LocallyNameless
```

## Macros ##

For every representation, there are (identical) macros `@lambda` and `@λ`, which convert Julia
syntax to the respective `Term` objects by transforming expressions on a syntactic level to the
corresponding constructor calls:

```Julia
julia> @macroexpand LambdaCalculus.DeBruijn.@lambda (x -> x)(y)
:((LambdaCalculus.DeBruijn.App)((LambdaCalculus.DeBruijn.Abs)((LambdaCalculus.DeBruijn.Var)(1)), (LambdaCalculus.DeBruijn.Var)(1)))
```
Other expressions can be “spliced in” by the usual interpolation syntax:

```Julia
julia> @macroexpand LambdaCalculus.Named.@lambda $id(y)
:((LambdaCalculus.Named.App)(id, (LambdaCalculus.Named.Var)(:y)))
```

For `DeBruijn` terms, there’s a special additional method of the macros by which a context of free
variables can be specified (which is sometimes needed in order to get indices right):

```Julia
julia> LambdaCalculus.DeBruijn.@lambda [x, y] (x -> x)(y)
((λ.⟨1⟩) ⟨2⟩)

julia> LambdaCalculus.DeBruijn.@lambda (x -> x)(y)
((λ.⟨1⟩) ⟨1⟩)

```

## Conversions ##

Terms can in general be converted between representations by `Base.convert`.  There are always
methods which take an additional argument of type `NamingContext`, which provides a sequence of free
variables which should be used for indexing, if necessary.  Otherwise, fresh names will be chosen
automatically according to some default schemes.


## Syntactic functions and evaluation ##

For all representations, there are common syntactic functions like `alpha_equivalent`, `evaluate`,
`freevars`, or `substitute`.  Additionally, some special ones for specific representations are
provided:

- For `DeBruijn`, there’s `shift` for shifting indices
- `LocallyNameless` has `openterm` and `closeterm`, the dual operations for working under binders,
  and the predicate `is_lc` for determining local closedness (the property that no “dangling
  indices” occur).
  
Further, for (currently) `DeBruijn` and `LocallyNameless`, evaluation functions are provided in the
form of `evaluateonce`, which performs one β-reduction if possible and otherwise returns `nothing`,
and `evaluate`, which reduces until a normal form is found.  Reduction is always done in normal
order.


## Boltzmann samplers ##

Samplers for De Bruijn terms use the Boltzmann sampling technique described in the Grygiel/Lescanne
paper.  There are two instances of `Random.Sampler{DeBruijn.Term}`:

- `GeneralTermSampler(x)` is a general Boltzmann sampler with parameter x.  There’s a constant
  `large_terms`, which chooses `x` such that the expected size of the terms is infinite.
- `BoundedTermSampler(lower, upper)` uses rejection sampling to ensure a length between `lower` and
  `upper`. 
  
