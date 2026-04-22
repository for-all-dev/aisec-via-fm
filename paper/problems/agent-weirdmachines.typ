// Tag: agent-weirdmachines
// Layers: execution-harness, orchestration-cloud
// Adversaries: malicious-model
// Category: enabler
// Authors: quinn, maxvh

#import "../common/fns.typ": related-layers, adversaries-blocked

== Formal Theory of Weird Machines in Agents <sec:agent-weirdmachines>

#related-layers("agent-weirdmachines")
#adversaries-blocked("agent-weirdmachines")

A weird machine @bratus2011weird is the unintended computational substrate an attacker programs when individually-legitimate operations compose into capabilities their designers never enumerated. LangSec @sassaman2013langsec named this and argued it is the root cause of most exploitation. Von Hippel @vonhippel2026sfo observes that the framing transfers directly to agentic harnesses: the "gadgets" are the tools the agent is permitted to call (`curl`, `cat`, `man`, a Python sandbox, a vector-store query), and the weird machine is whatever computation the tool set admits under composition. Adversarial agents will live off the land, and "is this permission set safe?" reduces to a question about the reachable states of a composed transition system no one has ever formally described.

@sec:capability-accumulation takes this seriously as a widget: specify a capability-safe tool interface in which well-typed compositions cannot reach exfiltration states by construction. That widget ships a type system and a soundness theorem; what it does not ship is the capability vocabulary the type system needs --- which labels matter, what counts as "reachable" across agent boundaries, what threshold separates safe composition from unsafe. That is the theoretical gap this enabler addresses.

The missing theory has two pieces. First, a notion of _capability threshold_: at what point does adding a tool push the composed system past a line that matters? Turing-completeness is the obvious threshold but not quite the right one --- a tool set that is Turing-complete over session-local state can still be safe if it cannot reach exfiltration channels, and a sub-Turing set can be lethal if one primitive is a `POST` to an attacker-controlled endpoint. We need a capability-theoretic analogue of complexity classes, indexed by what the tool set can _observably do to the world_ rather than what it can compute internally. Second, an inter-agent extension: once agents can message one another, the composition problem is distributed and gadgets cross agent boundaries. The classical weird-machines literature has no distributed analogue.

Von Hippel sketches two paths and picks one. The path he rejects (fn. 8 of @vonhippel2026sfo) is classical-LangSec-for-agents: cast tool invocations into a correct-by-construction language with inherent safety or runtime-observability guarantees. The path he prefers leans on cheap proofs to discharge safety obligations per deployment. The second is probably the right long-run bet, but it inherits its soundness from the theory being articulated here: proof oracles need to know what they are proving, and "this permission set does not induce a dangerous weird machine" is not currently a statement anyone can write down rigorously. The correct-by-construction path is still worth understanding, if only because it forces you to name the safety properties the proof oracles will be asked to verify.

This is an enabler rather than a widget because it does not ship a verified artifact. It produces a vocabulary --- capability classes, threshold lemmas, decidability results for bounded fragments --- that downstream widgets (@sec:capability-accumulation, @sec:verified-input-parsers) can target. Until that vocabulary exists, those widgets are verifying properties whose significance we can only argue informally.

=== Solution/project Sketch <sec:agent-weirdmachines-sketch>

Three threads, in rough dependency order.

_Capability-class hierarchy._ Adapt the existing process-algebra and IFC literature into a taxonomy of tool-set capabilities indexed by observable effects (read, write, exfiltrate, persist, escalate, signal). Formalize "tool set $T$ induces capability $C$" as a reachability predicate on the composed transition system. Identify fragments where the predicate is decidable (finite data, bounded steps, no unbounded recursion) and fragments where it is not. Deliverable: a `Lean` or `Rocq` library of definitions and a handful of threshold theorems.

_Distributed extension._ Lift the above to multi-agent settings where agents share a message channel. The relevant analogues are concurrent separation logic and session types --- the question becomes whether any protocol reachable from the permitted message grammar induces a capability the individual agents lack. Expect most interesting cases to be undecidable; the deliverable is a soundly over-approximating type system.

_Undecidability boundaries._ Prove Rice-style results pinning down where automated analysis of tool-set safety is and is not possible. This matters operationally: it tells harness designers which guarantees they can buy with static checking and which require runtime monitoring or per-session proof-oracle discharge.

The output of all three is papers and libraries, not deployable C code. That is the point of an enabler.
