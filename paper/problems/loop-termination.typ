// Tag: loop-termination
// Layers: execution-harness
// Adversaries: malicious-model
// Category: widget
// Authors: quinn, maxvh

#import "../common/fns.typ": related-layers, adversaries-blocked

== Agent Loop Termination and Budget Enforcement <sec:loop-termination>

#related-layers("loop-termination")
#adversaries-blocked("loop-termination")

Agentic loops run until they terminate, and if they don't terminate, they don't stop. Resource budgets (step count, token count, wall time) are the standard defense, but the enforcement is ad hoc. Three recurring bugs. If the termination check runs _after_ tool dispatch rather than _before_, an off-by-one in the budget counter lets the agent squeeze in one extra call --- which may be the exfiltration call. If the budget is checked in application code that the agent can influence (e.g., by writing session state that the check reads), the bound is not a bound. If the budget counter is shared across concurrent sub-agents without synchronization, two children can each pass a "budget remaining" check and then both execute, overshooting the parent's budget.

The property is a small liveness claim about a small state machine: every execution eventually reaches a terminal state, the counter is monotonically non-decreasing, and the termination check precedes every dispatch. None of this is hard in principle; it is hard because the invariants are not written down anywhere, and the dispatch loop sits in application code alongside a lot of other concerns. This widget is explicitly orthogonal to capability-safe tool interfaces (@sec:capability-accumulation) --- a tight budget bounds how much weird computation an attacker can build, but budget correctness and capability attenuation are independent properties with independent proof obligations.

=== Solution/project Sketch <sec:loop-termination-sketch>

Specify the harness dispatch loop as a small-step transition system with one rule: if the budget counter is strictly less than the bound, advance by one and dispatch; otherwise halt. Verify as an LTL liveness property in `TLA+`, and verify the implementation against the spec in `Dafny` (managed-language harnesses) or `Frama-C` (C harnesses). The contract is a precondition on the dispatch function and a loop invariant on the agent loop; both are small enough that a reviewer can read them in one sitting. For concurrent sub-agents, model the shared budget as an atomic fetch-and-decrement and prove the monotonic non-negativity invariant with `Iris` or an equivalent concurrent separation logic. The deliverable is a verified reference dispatch loop, a fuzzing harness that stresses the budget-counter path against the spec, and a small `Dafny` library other harnesses can import.
