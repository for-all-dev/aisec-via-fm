// Tag: neuralese-governance
// Layers: execution-harness, software-framework, orchestration-cloud
// Adversaries: malicious-model
// Category: enabler
// Authors: quinn

#import "../common/fns.typ": related-layers, adversaries-blocked

== Governance and Interpretability of Neuralese Proof Stacks <sec:neuralese-gov>

#related-layers("neuralese-governance")
#adversaries-blocked("neuralese-governance")

table stakes is that proofs are cheap. We assume a proof oracle will make code and proofs that they're correct too cheap to meter.

One idea is that specs remain expensive, though, because we always want a human in the loop. Elicitation and validation of specs is really crucial.

But in the "specs are expensive, proofs are cheap" world, we assume some known trusted natural/human-written proof stack, like `Lean` or `Rocq` or `Verus`/`Z3`, is the substrate. What if this assumption is violated?

What if LeoGPT writes a new proof stack, where human interpretability is not a first class feature?

how do we do spec elicitation and validation _then_? how do we govern the proof oracle if we've never seen the syntax before?

TODO: flesh out.
