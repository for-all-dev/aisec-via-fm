// Tag: adversarial-robustness-fm
// Layers: software-framework, execution-harness
// Adversaries: malicious-model
// Category: enabler
// Authors: quinn, maxvh

#import "../common/fns.typ": related-layers, adversaries-blocked

== Adversarial Robustness of Formal Methods <sec:adversarial-robustness>

#related-layers("adversarial-robustness-fm")
#adversaries-blocked("adversarial-robustness-fm")

`Agda`'s issue label #link("https://github.com/agda/agda/issues?q=label%3Afalse")["false" on GitHub sits at the time of this commit at 10 open and 76 closed]. `Agda`'s issue label "false" tracks the _proofs of false_ that Agda allows or has allowed. `Rocq` runs the same play under a different name: the #link("https://github.com/rocq-prover/rocq/issues?q=label%3A%22kind%3A+critical%22")[`critical` label] is reserved for proofs of false. One asks, "isn't the whole point of a type theory that it be sound?"

So you see we have a problem. If ITP and other FM tools are not adversarially robust, scheming or reward hacking AIs will readily leverage novel zerodays to violate security properties.

@demoura2026watchersprovers discusses some of this to set up the #link("https://arena.lean-lang.org/")[`Lean` kernel arena]. TODO: elaborate.

Broadly, soundness issues in proof assistants arise from the tension between expressivity and ease of use on one side and consistency on the other. Every concession to ergonomics --- definitional extensions, universe polymorphism, coinduction, native compilation of the reduction machine, opaque conversion shortcuts --- is a place where the kernel can drift away from the logic it was supposed to implement.

TODO: zero in on `Lean` specifically, (James Henson?), discuss governance challenges and the slippery definition of the problem.

=== Solution/project Sketch <sec:adversarial-robustness-sketch>

Soundness bugs often arise due to the extreme complexity of a dependent type theory, who's proof checker we call a kernel (~5k LoC in Lean, 10-30k LoC in Rocq). One idea would be to express the language of the ITP, even the dependently typed one, in a simpler theory with a smaller kernel. So you could, in principle, simply write a model of your complicated dependent ITP in a simple, well-trusted target and check proofs there.

What you want is a system in the #link("https://en.wikipedia.org/wiki/Logic_for_Computable_Functions")[LCF tradition] (Milner's Logic of Computable Functions), whose defining discipline is that theorems are an abstract datatype and the only way to manufacture one is through a small fixed set of inference rules. That discipline is what makes the trusted core small, and it's preserved across systems with otherwise quite different logics: `HOL Light` @hollight_site and `HOL Zero` @holzero_site (classical higher-order logic), `Candle` @candle_site (HOL Light verified down through `CakeML`), and `Milawa` (a bootstrapped first-order prover in the `ACL2` lineage @Davis2007MilawaRewriter). `HOL Zero` gets the trusted core down to a few hundred lines. Push further --- verify the logic down to a large cardinal axiom, plus a model of the hardware, plus a small wrapper for actually running things --- and rough estimates put the state of the art around 10k lines of spec.

One approach, then, is to pick something simple and well-trusted --- ZFC or a variant, or a minimal LCF-style higher order logic, augmented with a large cardinal / large universe axiom --- and reduce a working ITP all the way down to that. Useful prior art and reference points: #link("https://github.com/digama0/lean4lean")[`lean4lean`] (a verifier for `Lean 4` written in `Lean 4`) and the `MetaRocq` (formalised metatheory of `Rocq` inside `Rocq`).
