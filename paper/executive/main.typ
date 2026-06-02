= Executive Summary <sec:executive-summary>

// TODO(quinn): overhaul this prose. Scaffolding only.

== How to read this document <sec:how-to-read>

The document has two halves. @sec:stack walks the five layers of the ML training and inference stack --- execution harness, software/ML framework, orchestration and cloud, firmware and low-level systems, hardware and physical supply chain --- and, for each, sketches the status quo and how attackable it is. @sec:tractable-problems is the payload: a list of concrete problems, each tagged by which layers of the stack it touches and whether it is an _enabler_ (unbottlenecks a class of downstream work) or a _widget_ (a scoped, shippable artifact). The website at #link("https://tractable.for-all.dev")[tractable.for-all.dev] mirrors the same content, with the layer/problem tagging exposed as a many-to-many filter.

== What formal methods can and can't claim <sec:fm-primer>

#figure(
  image("/executive/fm-gap.svg", width: 100%),
  caption: [After Evan Miyazono. Formal verification only closes the middle gap; the elicitation gap on the left is out of scope for the proof itself, and the modeling gap on the right is only as good as the model of the system the proof is stated against. Both ends are where most real-world failures live.],
) <fig:fm-gap>

== Quick primer on formal methods

#lorem(40) // TODO(quinn)

== What we count as tractable <sec:scope>

Three working principles narrow the problem list in @sec:tractable-problems.

=== Mechanism, not policy <sec:mechanism-not-policy>

Verification has the most leverage on the mechanisms that establish system integrity --- microkernels, hypervisors, drivers, network protocols --- and the least on the policies layered on top of them. Container scheduling on `Kubernetes` is the canonical example: a scheduler that places pods optimally produces a faster answer, not a more correct one, and verifying its placement decisions does not improve isolation between tenants if the underlying runtime is unsound. We accordingly scope the orchestration layer (@sec:orchestration-cloud) to its mechanism content --- distributed-protocol correctness, IAM logic, network-fabric isolation, runtime confinement --- and treat scheduler optimization as out of scope. The same line shows up at every layer: there is a verifiable mechanism underneath, and a policy or optimization above it whose correctness is downstream of the mechanism's.

=== Small API surfaces are reachable; large ones are not <sec:api-surface>

Compare `NOVA`'s 16-hypercall interface to the `POSIX` surface that `Linux` exports, or to the API a `Docker` daemon exposes through its versions. The first is small enough to specify and prove against; the others balloon with each release and have no single coherent specification to target. Tractability tracks API size more reliably than it tracks codebase size --- a small interface in front of a large implementation is a verification target, a large interface is not. This shapes the widget specs in @sec:tractable-problems toward the smallest customer-relevant subset --- the 10 or 25 functions a real workload actually uses --- rather than full-coverage proofs of sprawling APIs.

=== Separable, language-agnostic specifications <sec:separable-specs>

A system's specification should be separable from its implementation, both technically (so a `Rust` rewrite of a `C++` component does not invalidate the proof effort) and legally (so an open spec can be referenced by implementations under stricter licenses). `NOVA` is the existence proof: the implementation is GPL-2 (Intel and TU Dresden) while the specification is licensed separately under Blue Rock @bluerocksec2024nova. The same separation is what would let a `Linux` retrofit happen without forcing every maintainer onto a single proof toolchain. We treat separability as a precondition: a widget that cannot factor cleanly into spec-and-implementation is one we cannot recommend, regardless of how shippable the implementation looks.

== Why this is hard to fund <sec:roi>

The honest difficulty: formal methods compete in a market where the unverified alternative is usually free. A startup considering whether to buy a verified hypervisor over `KVM`, or a verified container runtime over `runc`, is comparing a paid product against a zero-marginal-cost open-source incumbent that is good enough for the threat model the customer thinks they have. The ROI calculation is upside-down before the conversation starts. This is the central reason the formal-methods talent that exists today is concentrated in domains --- avionics, defense, automotive --- where regulators force the comparison to be against a counterfactual incident rather than against the free alternative.

The document does not solve this problem, but it tries to make the right cases visible. For each tractable problem in @sec:tractable-problems, we name the threat model the verified component would close, the alternatives a buyer is implicitly comparing it against, and the lift to deliver a usable artifact rather than a research prototype. AI infrastructure is one of the few private-sector settings where the counterfactual incident is large enough to invert the calculation --- model weight exfiltration, training-data poisoning, or container escape from an agentic workload are losses on the order of the model's training cost --- and where the customers (frontier labs, regulated downstream deployers) have both the budget and the risk model to act on it. Public money is now in play too: the June 2026 executive order directs OMB to identify federal grant funding for AI vulnerability detection @whitehouse2026aiinnovationsecurity, a channel that could underwrite the early widgets in @sec:tractable-problems before any private buyer's ROI flips. Making the business case requires actually writing it down. That is what this document is.

