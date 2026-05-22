// Tag: audit-log-integrity
// Layers: execution-harness, orchestration-cloud
// Adversaries: malicious-model, rogue-insider
// Category: widget
// Authors: quinn, maxvh

#import "../common/fns.typ": related-layers, adversaries-blocked

== Audit Log Integrity and Session State Channels <sec:audit-log-integrity>

#related-layers("audit-log-integrity")
#adversaries-blocked("audit-log-integrity")

The audit log is the primary accountability mechanism for deployed AI systems. Regulators, red teams, and incident responders all depend on the same thing: a complete, tamper-evident record of what the model did. If log entries can be suppressed, falsified, or selectively deleted, the system is unauditable --- and any safety claim that rests on "we can review the logs" collapses. Append-only storage and cryptographic log chaining (in the style of Certificate Transparency @laurie2014ct) provide tamper _evidence_, but the implementations are not formally verified. The gap between "we use Merkle trees" and "no API call sequence available to the serving infrastructure can modify a committed entry" is exactly the gap formal methods fills.

There is a subtler problem on the same boundary. When a model's output or summary is written back to session state for future context windows, a persistent side channel is created. A misaligned model can encode messages in session state that survive request boundaries --- instructions to future invocations of itself, breadcrumbs for capability accumulation, or data staged for later exfiltration. This channel is invisible to the output filter, which inspects the response returned to the user, not the write-back to the session store. The threat model is not hypothetical: any system that persists conversation summaries, scratchpads, or tool-call results across requests has this surface.

The two problems are linked by a common structure: both involve a write path that must satisfy integrity constraints, and both fail silently when the constraints are violated. A corrupted log and a poisoned session store both look normal from outside the system until someone audits the contents --- and the audit itself depends on the log being intact.

=== Solution Sketch A: Log Integrity via Permission Graph <sec:audit-log-integrity-sketch-permission>

Build a `TLA+` model of the serving infrastructure's request lifecycle. State variables: the committed log, the in-flight request set, the per-principal permission relation. Transitions: a request enters the gateway, dispatches to forward-pass execution, emits a log entry, commits the entry to storage, returns a response. Two properties discharge against the same model. _Tampering safety_: in every reachable state, no transition available to any principal (model, harness, orchestrator) modifies or deletes an already-committed log entry --- a safety check over the permission relation and the storage state machine. _Logging completeness_, the liveness counterpart: every request that reaches forward-pass execution is eventually followed by a log-commit transition before the corresponding response-emit transition, catching suppression by the same infrastructure that handles writing. Sketch A treats the log as a passive resource and verifies the surrounding access-control and lifecycle machinery that protects it.

=== Solution Sketch B: Log Integrity via Verified Merkle-Tree Log <sec:audit-log-integrity-sketch-merkle>

An alternative architecture closes the same gap from the other direction: rather than verifying that the permission system prevents tampering, make tampering cryptographically detectable inside the log itself. Append-only Merkle-tree logs of the kind Certificate Transparency @laurie2014ct uses (also `sigstore`'s `Rekor` @newman2022sigstore) publish signed tree heads that any third party can use to check, via consistency proofs, that two published heads belong to the same history. A serving infrastructure that retroactively removes a committed entry cannot then issue a new signed head consistent with the previous one --- the tamper-evidence rests on the structure, not on the access-control system.

The verification target is the log component itself, against an abstract specification of an append-only Merkle log. Three local properties:

+ The `append(entry)` operation produces a tree whose root is a valid extension of the previous root; no implementation path produces a signed root that omits a previously committed entry.
+ `consistency_proof(old_root, new_root)` is sound (it only verifies for genuinely-consistent trees) and complete (it verifies whenever the trees are consistent).
+ The signing operation has no path that produces a signed tree head for a tree the log did not append to in order.

These are local properties of a single program and discharge cleanly in `Dafny` or `F*` as a refinement against the abstract spec. The result is a verified log component whose tamper-evidence guarantees rest on a small cryptographic structure rather than the permission graph surrounding it --- a property that any third party with two signed tree heads can re-check independently of the operator, which Sketch A's approach cannot offer. Sketch A and Sketch B are alternatives: pick one (or run both, treating Sketch B's verified log as the storage primitive Sketch A's permission model protects).

=== Solution Sketch C: Session State via Noninterference <sec:audit-log-integrity-sketch-session>

For the persistent-side-channel problem, apply information flow analysis. Model the session store as shared memory and the write-back function as the interface under test. The noninterference property: the content written to session state must be a function only of authorized inputs (the model's declared output schema, the user's message, the tool results). Any information flow from the model's hidden state to the session store that is not mediated by the declared output path is a violation. This is verifiable as a pre/postcondition contract on the write-back function --- specify the allowed content, prove the function produces only that content. `Dafny` is a natural fit: the write-back function is small, the specification is a refinement type on the output, and the verifier handles the quantifier reasoning automatically.
