// Tag: audit-log-integrity
// Layers: execution-harness, orchestration-cloud
// Adversaries: malicious-model, rogue-insider
// Category: widget
// Authors: quinn, maxvh

#import "../common/fns.typ": related-layers, adversaries-blocked

== Audit Log Integrity and Session State Channels <sec:audit-log-integrity>

#related-layers("audit-log-integrity")
#adversaries-blocked("audit-log-integrity")

Incident response, red-teaming, and any after-the-fact review of a deployed model all assume a complete, tamper-evident record of what the model did. If log entries can be suppressed, falsified, or selectively deleted, a safety claim that rests on "we can review the logs" is unsupported. Append-only storage and cryptographic log chaining (in the style of Certificate Transparency @laurie2014ct and tamper-evident history trees @crosby2009tamperevident) provide tamper _evidence_, but the deployed log servers that serving infrastructure would use, such as `sigstore`'s `Rekor` @newman2022sigstore, are not shipped with machine-checked proofs.

There is a subtler problem on the same boundary. When a model's output or summary is written back to session state for future context windows (the text prepended to later requests), the write-back opens a persistent covert channel in Lampson's sense @lampson1973confinement. A misaligned model @greenblatt2024aicontrol can encode messages in session state that survive request boundaries, such as instructions to future invocations of itself or data staged for later exfiltration. The output filter (the gateway-side check on the response returned to the user) never sees the write-back to the session store, so it cannot catch this. Any system that persists conversation summaries, scratchpads, or tool-call results across requests exposes this surface.

Both problems sit on a write path out of the serving loop, and in both cases a violation is invisible until someone inspects the stored contents.

=== Solution Sketch A: Log Integrity via Permission Graph <sec:audit-log-integrity-sketch-permission>

Build a `TLA+` @lamport2002specifying model of the serving infrastructure's request lifecycle. State variables: the committed log, the in-flight request set, the per-principal permission relation. Transitions: a request enters the gateway, dispatches to forward-pass execution, emits a log entry, commits the entry to storage, returns a response. Three properties are checked against the same model.

- _Tampering safety_: in every reachable state, no transition available to any principal (model, harness, orchestrator) modifies or deletes an already-committed log entry.
- _Log-before-response_ (also a safety property): no response-emit transition for a request fires unless that request's log-commit transition has already fired. This catches suppression by the same infrastructure that handles writing.
- _Logging completeness_ (liveness): every request that reaches forward-pass execution eventually has its log entry committed.

The model is not the gateway. The result is only as good as the correspondence between the `TLA+` transitions and the deployed components, so the sketch should budget for closing that gap, via trace validation against production logs or conformance tests generated from the model. Sketch A treats the log as a passive resource and verifies the access-control and lifecycle machinery around it.

=== Solution Sketch B: Log Integrity via Verified Merkle-Tree Log <sec:audit-log-integrity-sketch-merkle>

Instead of verifying that the permission system prevents tampering, make tampering detectable from the log's own structure. Append-only Merkle-tree logs @crosby2009tamperevident of the kind Certificate Transparency @laurie2014ct and `Rekor` @newman2022sigstore use publish signed tree heads. Any third party can use them to check, via consistency proofs, that two published heads belong to the same history. A serving infrastructure that retroactively removes a committed entry cannot then issue a new signed head consistent with the previous one.

The verification target is the log component itself, against an abstract specification of an append-only Merkle log. Two local properties:

- _Append-only signing_: the only path to the signing operation runs through `append(entry)`, and every signed root is a valid extension of the previously signed root. No implementation path signs a root that omits a previously committed entry.
- _Consistency-proof correctness_: `consistency_proof(old_root, new_root)` is sound (a proof verifies only for genuinely consistent trees) and complete (an honestly generated proof always verifies).

Both are local properties of a single program, a good fit for a refinement proof against the abstract spec in `Dafny` @leino2010dafny or `F*` @swamy2016fstar. Soundness is necessarily conditional: it holds relative to an explicit collision-resistance assumption on the hash, which the proof states as an axiom rather than discharges.

The result is a log component whose tamper-evidence follows from the Merkle structure, not from the permission graph around it. Unlike Sketch A, its guarantee can be re-checked by any third party holding two signed tree heads, independently of the operator. That requires the heads to actually reach independent parties: an operator who shows different heads to different auditors (equivocation) defeats the check unless heads are gossiped or co-signed by witnesses, and that distribution protocol is outside this sketch.

Sketch B does not replace Sketch A. A Merkle log makes tampering with _committed_ entries detectable, but says nothing about entries that are never committed. Logging completeness and log-before-response remain Sketch A's job. The natural combination uses Sketch B's verified log as the storage primitive whose access path Sketch A's model covers.

=== Solution Sketch C: Session State via Noninterference <sec:audit-log-integrity-sketch-session>

For the session-state channel, apply information flow analysis @myers1999jflowpractical. A naive noninterference property, that session state depends only on "authorized" inputs such as the model's declared output, does not help: the declared output is itself a function of the model's hidden state, and a model encoding messages steganographically does so _through_ the declared output.

The useful property is narrower. Session state must be a deterministic function of what was already exposed to monitoring: the user's message, the tool results, and the response _as delivered after the output filter_. Stated as noninterference @goguen1982noninterference: for any two runs that agree on those inputs, but differ in anything else the model produced (undelivered scratchpad, discarded drafts, fields the filter strips), the write-back function produces identical session state. This does not eliminate steganography in the visible response. It collapses the persistent channel onto the channel the output filter already inspects, so no unmonitored path into future context remains.

The write-back function is small and its specification is a pre/postcondition contract on its output, so `Dafny` @leino2010dafny fits. The relational two-run form of the property needs either a product-program encoding (two copies of the function run side by side and their outputs compared) or a relational verifier.
