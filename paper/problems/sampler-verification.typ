// Tag: sampler-verification
// Layers: software-framework, execution-harness
// Category: widget
// Authors: quinn, maxvh

#import "../common/fns.typ": related-layers

== Sampler Integrity and Determinism <sec:sampler-verification>

#related-layers("sampler-verification")

The sampler is the last piece of code between the model's output logits and the token that reaches the user. It applies temperature scaling, top-_k_ or top-_p_ filtering, and then draws from the resulting distribution. This is a small amount of code --- a few hundred lines in a typical inference server --- but it sits at a chokepoint. An adversary who controls the temperature parameter, the random seed, or the filtering threshold can bias the output distribution without touching weights or the forward pass. The attack surface is not hypothetical: inference servers expose these parameters via API, configuration files, and environment variables, and the sampler's internal state (particularly the PRNG) is rarely isolated from the rest of the serving process.

The scoping here is what makes the problem attractive. Unlike weight loading or kernel validation, the sampler is small enough to verify in its entirety. The specification is a probability distribution parameterized by (logits, temperature, top-_k_, top-_p_, seed), and the property to check is that the implementation samples from exactly that distribution --- no hidden state, no side-channel inputs, no drift from the spec across calls.

=== Solution/project Sketch <sec:sampler-verification-sketch>

Specify the sampler as a probabilistic program and verify it with a probabilistic model checker (PRISM or Storm). The key property: for any input logit vector, the output token distribution is within a specified KL-divergence bound of the theoretical distribution defined by the declared parameters. This catches both outright bugs (off-by-one in top-_k_ filtering) and subtle manipulation (PRNG state leaking information across requests). Separately, prove data-flow integrity on the implementation --- that the sampler is a pure function of its declared inputs with no dependence on mutable global state or memory reachable from other threads. This is a standard information-flow analysis, tractable for code this size. The combination of distributional correctness and data-flow purity gives you a sampler you can trust at the boundary between model and user.
