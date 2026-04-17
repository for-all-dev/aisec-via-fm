// Tag: ai-control-proof-carrying-code
// Layers: execution-harness, software-framework, orchestration-cloud
// Adversaries: malicious-model
// Category: enabler
// Authors: quinn

#import "../common/fns.typ": related-layers, adversaries-blocked

== AI Control via Proof-Carrying Code <sec:proof-carrying-code>

#related-layers("ai-control-proof-carrying-code")
#adversaries-blocked("ai-control-proof-carrying-code")

Proof-carrying code @necula1997pcc and AI Control @greenblatt2024aicontrol @bhatt2025ctrlz are two literatures about the same problem: keep an untrusted producer on the far side of an interface and let only a small trusted checker decide what gets through. PCC's answer is that every proposed action arrives tagged with a machine-checkable certificate; the trusted base is the proof kernel and nothing else. AI Control's answer is that a weaker trusted monitor, backed by a scarce audit budget, decides per-action on a safety--usefulness Pareto frontier. The deterministic midpoint --- the untrusted agent emits code plus a proof in a standard ITP, the boundary rejects anything that does not typecheck, and the trusted base collapses to the kernel plus a human-written specification --- has been sketched at prototype scale @dougherty2025formalconfinement but not stress-tested.

The question this enabler addresses is whether that synthesis can actually pay for itself. Classical PCC was designed for a world where proofs were written by compiler-level procedures on statically-known properties. Extending it to a world where the code producer is a frontier model and the safety property is "this action does not compromise the serving stack" raises a quantitative issue: the _verification burden_ $k$ --- the ratio of proof-synthesis cost to program-synthesis cost. A world where $k$ is small is a world where AI-control-via-PCC is the right architecture for most widgets in this document. A world where $k$ is large --- or where it is small only for spec-shapes nobody writes in practice --- is a world where those widgets have to be verified individually, outside any unified control protocol.

Three open subproblems determine where $k$ lands.

_Proofs as a matter of degree._ Current type checkers give a binary signal: the proof closes or it does not. A partial proof that is ninety percent of the way to closure is indistinguishable, to the kernel, from a partial proof that is ten percent there. A control protocol that could read _how close_ a submitted proof is to closing --- via a learned value function over tactic sequences, a conditional-probability estimate on the remaining subgoal structure, or a simpler admissibility heuristic --- could admit "warm" proofs under bounded risk and reject "cold" ones as likely unprovable. This replaces the all-or-nothing gatekeeper with a graded one, and the grading itself becomes a research target.

_Specialist blue-team models._ Nothing in the AI Control framing requires the trusted checker to be a general model. A small model fine-tuned on a specific Hoare fragment, with custom tactics targeting a specific surface (context-window bookkeeping, permission-attenuation lemmas, IFC label discharge), exploits the asymmetry that verification is sometimes provably cheaper than generation. The training cost is upfront and amortized over deployment; the deployment cost is low by construction. The open question is how much of the security-relevant spec space admits specialists this way.

_Upfront versus ongoing investment._ The seL4 project @klein2009sel4 spent roughly $2.2$ person-years on kernel design and coding, $9.0$ on reusable infrastructure and tooling, and $11.0$ on kernel-specific proof engineering --- roughly a $1:1$ ratio of better-swords to more-fencing. In a PCC-for-AI world, who pays for the tooling half? If the red team pays --- compliance as a cost of doing business, on the SOC-2 model --- the original Ctrl constraint that _blueteam_budget_ much-less-than _redteam_budget_ dissolves, and the verification-burden arithmetic changes sign. If the blue team pays, the constraint binds and the first two subproblems become load-bearing.

=== Solution/project Sketch <sec:proof-carrying-code-sketch>

Four threads, sequenced by how much they unblock.

_Verification-burden measurement at scale._ Measure $k$ on the spec shapes that actually matter for this document: context-window allocation (@sec:context-window-integrity), sampler conformance (@sec:sampler-verification), tool-composition safety (@sec:capability-accumulation, @sec:agent-weirdmachines), and weight-load refinement (@sec:weight-integrity). Produce $k$ distributions per spec class, per model, per year. This is an ongoing benchmark, not a one-shot paper.

_Warmness metrics and graded gatekeeping._ Build partial-proof signals into a control protocol. Start with `Lean` tactic-sequence value functions trained on human and synthetic proof traces, extend to subgoal-structure embeddings, and evaluate as a replacement for binary pass/fail in a backdoored-code testbed in the style of @greenblatt2024aicontrol. The deliverable is a graded gatekeeper with a published ROC curve on audit-budget-vs-catastrophe-rate.

_Specialist-checker training._ Pick one narrow spec surface --- say, Hoare logic over the context-assembly allocator --- and train a small model specifically for its proof obligations with custom tactics. Measure the specialist's $k$ against a general model's $k$. Repeat across surfaces until the specialist-viability boundary is clear.

_Control protocols as a programming language._ Speculative and out-of-scope for the near-term, but worth naming. The Dolev-Yao model @dolev1983dyprotocols reduced cryptographic-protocol reasoning to logic programming and absorbed a class of attacks into definitional unreachability. An AI-control analogue --- a process calculus in which resampling, deferral, and trusted-editing primitives have first-class semantics and attacker capabilities are syntactic --- would let protocol designers discharge parts of the soundness argument at design time rather than per deployment. PLT or FV researchers looking for an entry point into AI safety should consider this direction.
