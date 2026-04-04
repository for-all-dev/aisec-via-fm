// Tag: adversarial-robustness-fm
// Layers: software-framework, execution-harness
// Category: enabler

#import "../common/fns.typ": related-layers

== Adversarial Robustness of Formal Methods <sec:adversarial-robustness>

#related-layers("adversarial-robustness-fm")

Agda's issue label #link("https://github.com/agda/agda/issues?q=label%3Afalse")["false" on GitHub sits at the time of this commit at 10 open and 76 closed]. Agda's issue label "false" tracks the _proofs of false_ that Agda allows or has allowed. One asks, "isn't the whole point of a type theory that it be sound?"

So you see we have a problem. If ITP and other FM tools are not adversarially robust, scheming or reward hacking AIs will readily leverage novel zerodays to violate security properties.

@demoura2026watchersprovers discusses some of this to set up the Lean kernel Arena (TODO: hyperlink to arena.lean-lang.org). TODO: elaborate.

TODO: go over the nature of the soundness bugs (ideally Jason writes this)

TODO: zero in on Lean specifically, (James Henson?), discuss governance challenges and the slippery definition of the problem.

=== Solution/project Sketch <sec:adversarial-robustness-sketch>

Soundness bugs often arise due to the extreme complexity of a dependent type theory, who's proof checker we call a kernel (TODO: lookup LoC). One idea would be to express the language of the ITP, even the dependently typed one, in a simpler theory with a smaller kernel. So you could, in principle, simply write a model of your complicated dependent ITP in a simple type theory like isabelle or even ACL2.
