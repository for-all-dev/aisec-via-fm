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

Soundness bugs often arise due to the extreme complexity of a dependent type theory, who's proof checker we call a kernel (TODO: lookup LoC). One idea would be to express the language of the ITP, even the dependently typed one, in a simpler theory with a smaller kernel. So you could, in principle, simply write a model of your complicated dependent ITP in a simple, well-trusted target and check proofs there.

The right target is not `Isabelle` --- that's the general framework, not the type theory --- but something on the LCF axis: `Candle`, `HOL Light`, `HOL Zero`, or `Milawa`. An LCF-style kernel can be made small; `HOL Zero` gets the trusted core down to a few hundred lines. If you go further and try to verify the logic down to a large cardinal axiom plus a model of the hardware plus a small wrapper for actually running things, rough estimates put the state of the art around 10k lines of spec.

One approach, then, is to pick something simple and well-trusted --- ZFC or a variant, or a minimal LCF-style higher order logic, augmented with a large cardinal / large universe axiom --- and reduce a working ITP all the way down to that. Useful prior art and reference points: #link("https://github.com/digama0/lean4lean")[`lean4lean`] (a verifier for `Lean 4` written in `Lean 4`), `MetaRocq` (formalised metatheory of `Rocq` inside `Rocq`), and the `critical` label on Rocq's issue tracker as a working corpus of the failure modes any such reduction has to survive.
