# anonymous model checking expert:

1. Edge Policy Verification [x]
   (2026-05-22: split into two project sketches inside `edge-policy-verification.typ` — Sketch A merges auth + quota under the unified "principal X may send N requests in window T" framing; Sketch B handles agent-authority attenuation as a confused-deputy / capability containment problem.)

I'm not as familiar with the industry side of this, how much of these protocols is actually public vs proprietary black-box implementation? 
I imagine an external researcher (i.e. unaffiliated with one of the concrete AI vendors that could give access to the internals) might have a tough time
formalizing the protocol simply due to the access barrier.

I think this is actually two separate projects. One is an industry-internal formalization of the auth protocol, and the other is a more security-focused exploration
of permissions handling on top of the protocol layer ("authorization for agent-originated requests"). The latter one, imo, is more concerned with how to design payloads s.t. the
various kinds of interception attacks can't happen as opposed to the raw protocol interaction.
The former combines "authentication correctness" and "quota enforcement", since, at least to me, they read as abstractly the same property: Each of X users may send Y messages in Z interval.

2. Capability Accumulation and Loop Termination [x]
   (Commits 74fea852 / 775b9da9 in April: split into two problems and rewrote `capability-accumulation.typ` as "Capability-Safe Tool Interfaces" with an object-capability framing; 2026-05-22: `loop-termination.typ` deleted outright, so the "reachability ∧ termination" bundling the expert flagged is gone.)

I think this one might be tough, since it's too generic of an ask. Intuitively, the issue lies in formalizing "which tools is the AI allowed to use and what to they do?". Pick too few and it's trivial,
pick too many and it may give a model where functionally any path can exfiltrate, which lack nuance. 
And that's before you even combine your reachability problem with termination, which is a somewhat orthogonal layer of complexity.

3. Audit Log Integrity and Session State Channels [x]
   ("Why not blockchain": addressed 2026-05-22 — added Sketch B in `audit-log-integrity.typ`: a verified Merkle-tree append-only log against a Certificate-Transparency / Rekor-style structure, framed as an explicit alternative to the permission-graph approach. Avoids the b-word but covers the same architectural alternative. "Pick one formalism, don't mix": addressed 2026-05-22 — Sketch A was Alloy + TLA+, now consolidated to TLA+ alone (one model, two properties — tampering safety and logging-completeness liveness — both expressible in the same lifecycle state machine). Each of the three sketches now uses a single formalism: A is TLA+, B is Dafny/F*, C is Dafny.)

I suppose the obvious question here, that you should at least address in the proposal is, if you want a "a complete, tamper-evident record of what the model did", why not use a blockchain
(not that I necessarily think this would be a good idea, but you can't not mention it imo).

On a pragmatic level, mixing Alloy and TLA+ (or Dafny) for modeling might be impractical, and imposes the burden of, once you have the 2 models, showing that they're actually modeling the same thing, which is nontrivial; just pick one and run with it.

Aside from that, I think the idea here feels generally well-scoped, though I'm not personally familiar with AI audit logs so I can't speak on the nuances of the tach and the auditing.

4. Scheduler Integrity and Co-Tenancy Isolation [x]
   (Commits 74fea852 / 775b9da9 in April: `scheduler-cotenancy.typ` rescoped to shared-tenancy deployments — concedes dedicated hardware is the dominant real-world mitigation — and reframes the formal target from "identify dangerous co-locations" (not answerable a priori) to "prove the scheduler enforces the operator's isolation policy.")

The thing I see as the issue here is that problematic co-tenancy is a post-factum assessment; an attacker knows their target, and a victim of the attack can (with the host's info) potentially recover the identity of
the attacker (more precisely, the identity by which they're known as by the host) after they've been attacked, but how do you, in a real scenario, identify the attackers ahead of time ("which tenant pairs must never share a cache domain")?

It's not clear to me how the outcomes of this research could lead to better implementations without knowing ahead of time who's guarding agaist whom, and besides, 
to my knowledge, the hyper-concerned customers purchase non-shared hardware from their hosts anyway.

TLDR, I like 1 and 3 the most as potential projects, I think 2 is hard to scope, and 4 is hard to define and/or avoidable in practice.
