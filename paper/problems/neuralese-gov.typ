// Tag: neuralese-governance
// Layers: execution-harness, software-framework, orchestration-cloud
// Category: enabler

#import "../common/fns.typ": related-layers

== Governance and interpretability of proof stacks in neuralese <sec:neuralese-gov>

#related-layers("neuralese-governance")

table stakes is that proofs are cheap. We assume a proof oracle will make code and proofs that they're correct too cheap to meter.

One idea is that specs remain expensive, though, because we always want a human in the loop. Elicitation and validation of specs is really crucial.

But in the "specs are expensive, proofs are cheap" world, we assume some known trusted natural/human-written proof stack, like lean or rocq or verus/z3, is the substrate. What if this assumption is violated?

What if LeoGPT writes a new proof stack, where human interpretability is not a first class feature?

how do we do spec elicitation and validation _then_? how do we govern the proof oracle if we've never seen the syntax before?

TODO: flesh out.
