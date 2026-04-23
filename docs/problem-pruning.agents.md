# Problem Pruning — Reviewer Feedback TODO

Reviewer feedback (2026-04-24) flagged two problems as not making sense:

- `paper/problems/context-window-integrity.typ` — "Context Window Integrity Under Adversarial Length"
- `paper/problems/capability-accumulation.typ` — "Capability Accumulation and Loop Termination"

(Note: `capability-accumulation.typ` and `loop-termination.typ` are separate files; the reviewer's phrasing bundles them. Clarify with Quinn which one(s) they mean before acting.)

**Action:** consider deleting these problems. Before removing, check:
- whether they're referenced from `paper/main.typ` or any chapter
- whether tags / website relations reference them
- whether earlier reviewer feedback (`docs/feedback/mc-expert_1.md`) already criticized them — the mc-expert already raised concerns about "Capability Accumulation and Loop Termination" being too generic

Do not delete unilaterally — surface to Quinn for decision.
