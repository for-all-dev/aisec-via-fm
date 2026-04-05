// Tag: scheduler-cotenancy
// Layers: orchestration-cloud
// Category: widget
// Authors: quinn, maxvh

#import "../common/fns.typ": related-layers

== Scheduler Integrity and Co-Tenancy Isolation <sec:scheduler-cotenancy>

#related-layers("scheduler-cotenancy")

The cluster scheduler --- Kubernetes, Slurm, or a custom allocator --- decides which physical host runs which job. This is a security-relevant decision: an adversary who can influence placement (by timing job submissions, exploiting bin-packing heuristics, or compromising the scheduler API) can force co-location with a target tenant. Once co-resident on the same host, well-documented cache side-channel attacks (Flush+Reload @yarom2014flushandreload, Prime+Probe @liu2015llcsidechannel) can extract model weights, activations, or training data from a victim job sharing the last-level cache or GPU memory fabric. The attack surface extends beyond confidentiality --- resource accounting errors in the scheduler allow attribution fraud, where one tenant's GPU-hours are billed to another, or where a malicious job consumes more than its allocated share without detection.

Current mitigations are policy-based: anti-affinity rules, dedicated node pools, namespace quotas. These work when configured correctly, but the scheduler's placement logic is a constraint solver operating over dozens of dimensions (resource requests, affinity, taints, topology spread), and the interaction between constraints is hard to reason about by inspection. A misconfigured or under-constrained policy can silently permit co-location that the operator assumed was forbidden.

=== Solution/project Sketch <sec:scheduler-cotenancy-sketch>

Express the placement policy as formal constraints over a model of the cluster topology (hosts, LLC domains, GPU memory fabrics, network segments) and the tenant isolation requirements (which tenant pairs must never share a cache domain, which jobs require dedicated hosts). Verify via bounded model checking --- Alloy is a natural fit given the relational structure --- that the scheduler's constraint solver never produces a placement violating the isolation invariant, across all feasible cluster states and job arrival sequences. For resource accounting, model the metering pipeline (usage counters, aggregation, attribution) and prove with concurrent separation logic that the accounting invariant holds: every GPU-second is attributed to exactly one tenant, and the sum of attributed usage equals actual usage, even under concurrent job start/stop and preemption. The deliverable is a formal spec of the placement and accounting policies, a verified reference scheduler (or a verified shim that audits placement decisions from an existing scheduler), and a conformance test suite derived from the model's counterexample traces.
