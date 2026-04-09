= Executive Summary <sec:executive-summary>

// TODO(quinn): overhaul this prose. Scaffolding only.

== How to read this document <sec:how-to-read>

The document has two halves. @sec:stack walks the five layers of the ML training and inference stack --- execution harness, software/ML framework, orchestration and cloud, firmware and low-level systems, hardware and physical supply chain --- and, for each, sketches the status quo and how attackable it is. @sec:tractable-problems is the payload: a list of concrete problems, each tagged by which layers of the stack it touches and whether it is an _enabler_ (unbottlenecks a class of downstream work) or a _widget_ (a scoped, shippable artifact). The website at #link("https://tractable.for-all.dev")[tractable.for-all.dev] mirrors the same content, with the layer/problem tagging exposed as a many-to-many filter.

== What formal methods can and can't claim <sec:fm-primer>

#figure(
  image("/executive/fm-gap.svg", width: 100%),
  caption: [After Evan Miyazono. Formal verification only closes the middle gap; the elicitation gap on the left is out of scope for the proof itself, and the modeling gap on the right is only as good as the model of the system the proof is stated against. Both ends are where most real-world failures live.],
) <fig:fm-gap>

// TODO(quinn): write the primer. Core claims to land:
//  - verification ≠ validation: a proof discharges "the artifact meets the spec",
//    not "the spec captures what you wanted"
//  - proofs are relative to a model of the system; the model can be wrong
//    (compiler bugs, hardware errata, side channels, etc.)
//  - what this buys you anyway: transitive guarantees, composition, cheap re-audit
//    after code changes, the ability to rule out entire bug classes
//  - why this matters for AI security specifically: the infra underneath the
//    model is conventional software, and the usual FM caveats apply unchanged

#lorem(40)

