// Tag: scheduler-cotenancy
// Layers: orchestration-cloud
// Adversaries: co-tenant, rogue-insider
// Category: widget
// Authors: quinn, maxvh

#import "../common/fns.typ": related-layers, adversaries-blocked

== Scheduler Integrity and Co-Tenancy Isolation <sec:scheduler-cotenancy>

#related-layers("scheduler-cotenancy")
#adversaries-blocked("scheduler-cotenancy")

The dominant real-world mitigation for co-tenant attacks is not a scheduler policy but a purchase order: hyperscaler customers with serious confidentiality requirements buy reserved or bare-metal capacity and opt out of shared tenancy entirely. This section is scoped to the deployment model where that option is not on the table --- mid-tier cloud providers, academic and national-lab clusters, and internal multi-team platforms at organizations without per-team hardware budgets. In that setting, the cluster scheduler (`Kubernetes`, `Slurm`, or a custom allocator) decides which physical host runs which job, and the correctness of that decision is load-bearing for any isolation claim the operator wants to make.

The framing matters because the question "which tenant pairs are adversaries" is not answerable a priori. An attacker knows their target; the operator, ahead of time, does not. So the tractable formal problem is not "identify dangerous co-locations" but "given an isolation policy the operator has specified, prove the scheduler enforces it". The placement logic is a constraint solver operating over dozens of dimensions (resource requests, affinity, taints, topology spread, GPU fabric topology), and the interaction between constraints is hard to reason about by inspection. A misconfigured or under-constrained policy can silently permit co-location the operator assumed was forbidden --- and the failure is detectable only post-factum, by which point the attacker has already been a co-tenant.

Resource accounting has none of this scoping difficulty. Attribution fraud (one tenant's GPU-hours billed to another) and quota evasion (a malicious job consuming more than its allocated share without detection) apply to every shared-tenancy deployment regardless of whether anyone is trying to side-channel anyone else. The metering pipeline --- usage counters, aggregation, attribution across concurrent job start/stop and preemption --- is a distributed accounting protocol with the same class of race conditions that make distributed rate limiting hard, and it admits the same class of formal treatment.

The residual confidentiality story --- cache side channels (Flush+Reload @yarom2014flushandreload, Prime+Probe @liu2015llcsidechannel) against a co-resident victim --- then becomes a secondary application of the same placement model: given a formally enforced policy, one invariant of that policy can be "no two jobs labeled _mutually-distrusting_ share an LLC domain or GPU memory fabric", and the same verification discharges it.

=== Solution/project Sketch <sec:scheduler-cotenancy-sketch>

Two workstreams, both grounded in policy-enforcement rather than threat identification.

First, accounting correctness. Model the metering pipeline (counters, aggregation, attribution) as a distributed state machine and prove with concurrent separation logic (`Iris` or equivalent) that the accounting invariant holds: every GPU-second is attributed to exactly one tenant, and the sum of attributed usage equals actual usage, under concurrent job start/stop, preemption, and node failure. This is universally applicable and does not depend on any adversary-identification assumption. The deliverable is a verified reference metering library with a concurrency-safe aggregation protocol, usable as a drop-in for existing schedulers.

Second, placement-policy enforcement. Model the cluster topology (hosts, LLC domains, GPU memory fabrics, network segments) and the operator-authored isolation policy (expressed as relational constraints over tenant labels and topology resources) in `Alloy` @jackson2002alloy. The verification question is not "is this policy the right policy" --- that is a business decision the operator owns --- but "does the scheduler's constraint solver, across all feasible cluster states and job arrival sequences, only produce placements that satisfy the stated policy". Counterexample traces from bounded model checking become a conformance test suite against a concrete scheduler (e.g., `Kubernetes` with a given set of affinity and taint rules). The deliverable is a policy-specification language, an `Alloy` model of a representative scheduler, and an audit shim that checks live placement decisions against the model.
