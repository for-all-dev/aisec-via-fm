// Tag: capability-accumulation
// Layers: execution-harness
// Adversaries: malicious-model
// Category: widget
// Authors: quinn, maxvh

#import "../common/fns.typ": related-layers, adversaries-blocked

== Capability-Safe Tool Interfaces <sec:capability-accumulation>

#related-layers("capability-accumulation")
#adversaries-blocked("capability-accumulation")

A single tool call in an agentic harness is usually benign. Read a file, run a shell command, make an HTTP request --- each is authorized individually by whatever permission system the harness enforces. The problem is composition: read file + shell exec + HTTP request = exfiltrate a secret key. No single call crossed a policy boundary, but the _sequence_ did. This is the weird machines problem @bratus2011weird applied to AI tool use: individually permitted calls compose into unauthorized capability.

The obvious response --- enumerate the tool set, encode it as a process algebra, model-check reachability of a "dangerous state" --- has two failure modes that make it a poor shovel-ready target. The dangerous-state predicate is itself the hard part: define it too narrowly (one fixed exfiltration path) and the verification is trivial; define it too broadly (any bit leaving the session) and every nontrivial tool set admits reachable violations. The analysis also targets the tool set _after_ it has been assembled --- by the time the model checker runs, composition has already happened, and the verifier's only lever is to refuse to ship. A "your agent is weird-machine-complete" diagnosis arrives too late to inform the design.

The alternative is to stop asking "is this tool set safe" and start asking "what does a tool interface look like such that safe composition is the default". Object-capability languages --- `E`, `Newspeak`, `Monte`, and at the OS level `Capsicum` @watson2010capsicum and `seL4`'s capability system @klein2009sel4 --- have decades of theory on this question, and none of it has been specialized to AI tool dispatch. The ambient-authority assumption pervading current tool protocols (a tool named `file_read` taking a path argument implicitly holds read authority over the entire filesystem, attenuated only by whatever the harness decides to do post-hoc) is exactly the assumption those languages refuse.

This widget is the correct-by-construction arm of the two-arm split von Hippel draws @vonhippel2026sfo between correct-by-construction tool languages and cheap-proofs-per-deployment. It is worth pursuing not because it displaces the per-deployment path, but because writing down what "safe composition" means in an interface forces the vocabulary that the per-deployment path also depends on. See @sec:agent-weirdmachines for the enabler that carries that vocabulary.

=== Solution/project Sketch <sec:capability-accumulation-sketch>

The deliverable is a tool-interface specification language with two properties. Every tool declares its capability footprint as a typed requirement --- what authority it needs, expressed as a labelled region of the session's capability set, not an ambient permission. Composition of tools is constrained by a flow-type system such that any well-typed agent program satisfies a declared non-exfiltration theorem by construction.

Three pieces.

First, a surface language. Extend an existing tool-declaration format (`MCP` schemas, `OpenAI` function-calling JSON) with capability annotations: each parameter carries a flow label, each return value carries a label, and the tool's behavior is a declared transformation between them. This is `Jif`-style @myers1999jflowpractical information-flow typing retrofitted onto tool APIs, with the additional constraint that authority is held as first-class capabilities (read-this-file, post-to-this-URL) rather than pool permissions (read-any-file).

Second, a type system. Given a set of annotated tools and an agent program (a trace or policy that composes them), the type checker accepts only compositions in which no high-label value flows to a low-label sink. The novelty is in the labels: they are capability references, not secrecy classes, so the non-interference theorem states that an attacker-reachable channel can only carry data whose provenance the capability graph permits.

Third, a reference implementation and soundness proof. Build the type checker in `Rocq` or `Lean`, prove progress-and-preservation against a small-step semantics of the tool-dispatch loop, and ship a compiler from the surface language to a thin runtime wrapper over an existing agent harness. A well-typed program cannot, by construction, compose the file-read + shell-exec + HTTP-post exfiltration chain, because the flow labels on the file contents do not match the labels the HTTP sink accepts --- not because the harness noticed and blocked the call, but because the program would not have type-checked.

What the project does _not_ do: it does not decide which capabilities to grant an agent for a given user task. That is a policy question, owned by whoever writes the agent's capability manifest. What the project delivers is a tool interface in which the manifest has teeth --- stated capabilities bound behavior by construction, not by runtime check.
