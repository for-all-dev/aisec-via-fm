// Tag: spec-elicitation
// Layers: execution-harness, software-framework, orchestration-cloud
// Adversaries: malicious-model
// Category: enabler
// Authors: quinn

#import "../common/fns.typ": related-layers, adversaries-blocked

== Specification Elicitation and Validation <sec:spec-elicitation>

#related-layers("spec-elicitation")
#adversaries-blocked("spec-elicitation")

If proofs are cheap and specs are expensive, then specs are the bottleneck. Every widget in this document terminates in a spec: a verified sampler is verified against _some_ statement of what a sampler should do, an OCI runtime is hardened against _some_ threat model, an IAM policy is checked against _some_ notion of least privilege. The spec is where human intent meets machine-checkable formalism, and it is the part that no proof oracle can write for you --- or rather, if a proof oracle writes it for you, you have quietly handed over the thing you were trying to keep.

Two subproblems:

- *Elicitation.* Getting the spec out of the stakeholder's head and into a formal language, without losing the parts they could not articulate. The classical software-engineering requirements-gathering literature is relevant but insufficient --- we need elicitation techniques that produce artifacts a kernel can consume, not prose a PM can sign off on.
- *Validation.* Convincing yourself that the spec you wrote is the spec you meant. A proof of `P` against the wrong `P` is worse than useless: it launders a bug into a theorem. TODO: cite the property-based testing / spec-mining literature.

TODO: discuss the relationship to @sec:neuralese-gov --- if the proof substrate is itself opaque, spec elicitation becomes unsolvable rather than merely hard, which is why we treat that as a separate enabler.

TODO: discuss differential specification (two independently elicited specs, checked for agreement) as a validation technique.

=== Solution/project Sketch <sec:spec-elicitation-sketch>

TODO: flesh out. Candidate directions: interactive spec-synthesis from examples, lightweight formal methods for spec sanity-checking, spec-level mutation testing, and human-factors work on what kinds of formal notation domain experts can actually read and write.
