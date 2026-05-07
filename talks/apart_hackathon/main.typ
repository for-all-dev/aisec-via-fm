#import "@preview/touying:0.7.3": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  footer: [Tractable Problems in AI Security via Formal Methods --- #link("https://tractable.for-all.dev")[tractable.for-all.dev] - Apart SPS Hackathon - Quinn Dougherty],
)

#set text(size: 22pt)

= Tractable Problems in AI Security via Formal Methods

== The one-sentence pitch

A document you can hand to any formal methods expert who is worried about AI safety, and walk away with a list of shovel-ready projects they can spend the next five postdoc-years on.

#pause

Or: take a requirements list off the document and pay them to build the widget.

== What formal methods can and can't claim

#figure(
  image("assets/fm-gap.svg", width: 70%),
  caption: [After Evan Miyazono. FM closes the middle gap only.],
)

== What FM can and can't claim, in words

- *Elicitation gap* (left): is the spec the thing we actually wanted? Out of scope for the proof.
- *Verification gap* (middle): does the implementation meet the spec? This is what FM does.
- *Modeling gap* (right): does the proof's model of the hardware/OS/network match reality?

#pause

Most real-world failures live on the ends. A widget without an honest story for both ends is not a widget.

== The ML stack, in five layers

+ *Execution harness* --- inference servers, sandboxes, API gateways
+ *Software & ML framework* --- compilers, PyTorch/JAX, dependency supply chain
+ *Orchestration & cloud* --- K8s/Slurm/Ray, fabric, IAM
+ *Firmware & low-level* --- hypervisors, device drivers, boot integrity
+ *Hardware & physical* --- RTL, secure enclaves, side channels

#pause

Each layer has a status quo and an attack surface. Each layer has FM-shaped widgets that would close part of it.

== Stack: who's attacking what

#pause

- A *co-tenant agent* breaks containment at L1 or L4.
- A *malicious model* with tool use breaks the sandbox at L1, the runtime at L3.
- A *supply chain* compromise lands in the loader at L2 or kernel binaries at L4.
- A *physical adversary* or insider goes after the fabric at L3 or the chip at L5.

#pause

The widgets pair off against these threats. The matrix on the website is the many-to-many of layers × problems × adversaries.

== The tractable problems

17 entries on the website. Two flavors:

#pause

- *Enablers* unbottleneck a class of downstream work. Examples: adversarial robustness of FM tools, neuralese governance, spec elicitation.
- *Widgets* are concrete, scoped deliverables. Examples: seL4 GPU drivers, OCI runtime hardening, verified network tap, weight integrity.

#pause

An enabler with many dependents should be addressed early. A widget contingent on an unsolved enabler should be sequenced accordingly.

== Deep dive: five widgets

I'll spend a slide or two on each.

+ Verified network tap
+ OCI runtime hardening
+ seL4 native GPU drivers
+ AI control via proof-carrying code
+ Adversarial robustness of FM

== Widget 1: Verified network tap

The threat: the SDN controller and fabric manager on a GPU cluster _are_ the thing whose compromise we are worried about. Their own logs cannot be evidence.

#pause

The artifact: a passive (or active OEO) tap on the fiber, with an FPGA capture path proven against an LTL contract. North-south at the datacenter edge, east-west for storage, sampled for compute.

#pause

Costs (Cankaya et al., 2026): under 0.01% of facility upfront for the edge tap; 0.3--0.75% for east-west. FPGA capture at 400 Gbps is a solved hardware problem (Arista 7130, Deutsche Börse).

== Verified network tap: the LTL contract

$ square ( "live_in"(p) &-> diamond_(<= D) "live_out"(p) ) & quad "(P1) forwarding completeness" \
  square ( "live_out"(p) &-> diamond.filled "live_in"(p) ) & quad "(P2) forwarding fidelity" \
  square ( "live_in"(p) &-> diamond_(<= D') "mon"("image"(p)) ) & quad "(P3) mirror completeness" \
  square ( "mon"(r) &-> diamond.filled (exists p. "live_in"(p) and "image"(p) = r) ) & quad "(P4) mirror soundness" \
  square ( "live_out"(p) &-> not "depends-on"(p, "mon-input") ) & quad "(P5) no back-channel" \
  square ( "fail" &-> square ( "live_in"(p) -> diamond_(<= D) "live_out"(p) ) ) & quad "(P6) fail-to-wire" $

#pause

P5 is the noninterference property that defeats verifier collusion. P6 is fail-open: a fault must downgrade to a transparent pass-through, never a link cut.

== Widget 2: OCI runtime hardening

`runc` was never designed to resist an adversary _inside_ the container. The CVE record reflects this.

#pause

When the workload is an agent with tool use --- writes code, executes it --- "process isolation" is not a security boundary.

#pause

Empirical work: BoxArena (Dougherty 2026) inverts the offensive framing. Fix the attacker model, vary the runtime. Five attack surfaces (fs, socket, process, network, syscall) across `runc`, `runsc`, `crun`, `Kata`.

== OCI hardening: what the verified version looks like

Decomposes into tractable pieces:

#pause

- A formal model of the Linux ABI surface a hardened container actually uses (\~80 syscalls, not 350+).
- A specification of the confinement policy (drop caps, read-only rootfs, seccomp allowlist, no-new-privs).
- A proof that the runtime's state machine preserves the policy across all reachable states.

#pause

Lineage: `CLInc` (Bevier 1989, gates to apps), `seL4` (Klein 2009, microkernel functional correctness). Same shape, different target.

== Widget 3: seL4 native GPU drivers

Multi-tenant GPU workloads run on hypervisors whose TCB is orders of magnitude too large to verify, with a proprietary ring-0 driver from the vendor.

#pause

Candidates to host an ML-grade GPU stack:
- `seL4` --- most complete proof, no GPU support at all.
- `NOVA` --- partial proof covers concurrency and weak memory, host/guest split built in.

#pause

The methodology (separation logic, abstract HW model) is settled. The blocker is that *the abstract hardware model does not exist*. No GPU vendor publishes a machine-checkable spec of their command processor.

== seL4 GPU: the actual scope

Pick the smallest useful surface: command submission for one open stack (`NVK`/`Nouveau` or an `AMDGPU` subset).

#pause

Property: _no sequence of guest-supplied command packets causes the driver to program an IOMMU mapping or issue a DMA outside the guest's declared memory region._

#pause

Two stopping points:
- Verified module against a stubbed hardware model --- shippable as reference.
- Same driver against a model co-developed with the vendor or with REMS (Sewell) --- the research contribution.

== Widget 4: AI control via proof-carrying code

Two literatures, one problem. Keep an untrusted producer behind an interface; let a small trusted checker decide what passes.

#pause

- *PCC* (Necula 1997): every action arrives with a machine-checkable certificate. Trusted base = proof kernel.
- *AI Control* (Greenblatt 2024, Bhatt 2025): trusted monitor, scarce audit budget, safety--usefulness Pareto frontier.

#pause

Midpoint: untrusted agent emits code _and a proof_. The boundary rejects anything that does not typecheck. Trusted base = kernel + human-written spec.

== AI Control via PCC: the key unknown

The *verification burden* $k$: ratio of proof-synthesis cost to program-synthesis cost.

#pause

- Small $k$ everywhere → AI-control-via-PCC is the right architecture for most widgets in this document.
- Large $k$, or small only for spec-shapes nobody writes → widgets must be verified individually.

#pause

Three subproblems determine where $k$ lands:
+ Proofs as a matter of degree (graded gatekeepers, not pass/fail).
+ Specialist blue-team models for narrow Hoare fragments.
+ Who pays for tooling --- red team's compliance budget, or blue team's?

== Widget 5 (enabler): Adversarial robustness of FM

`Agda`'s GitHub issue label "false" tracks proofs of false the type checker has admitted. 10 open, 76 closed at last count.

#pause

If the ITP's soundness can be broken by a clever agent, every verified artifact built on top inherits the vulnerability.

#pause

This is the enabler with the most dependents. A scheming model that finds a kernel zero-day defeats the entire stack of widgets in one shot. It also gates AI-control-via-PCC --- the trusted base in that protocol _is_ the kernel.

== Adversarial robustness: the sketch

Soundness bugs are downstream of the complexity of dependent type theory. The proof checker (kernel) is large.

#pause

One direction: express the language of the ITP in a smaller, simpler theory. Model a complicated dependently-typed kernel inside `Isabelle` or `ACL2`.

#pause

`Lean` Arena (#link("https://arena.lean-lang.org")[arena.lean-lang.org]) is the live red-team venue.

#pause

Also a governance question: who is the maintainer when the bug is found by an agent at 3am?

== Why this is hard to fund

The honest problem: FM competes in a market where the unverified alternative is _free_.

#pause

A startup choosing between a verified hypervisor and `KVM`, or a verified container runtime and `runc`, is comparing a paid product against a zero-marginal-cost incumbent that is good enough for the threat model they think they have.

#pause

FM talent today is concentrated in avionics, defense, automotive --- domains where regulators force the comparison to be against a counterfactual incident, not against the free alternative.

== Why AI infra inverts the calculation

AI infra is one of the few private-sector settings where:

#pause

- The counterfactual incident is _large_: weight exfiltration, training-data poisoning, agentic container escape. Losses on the order of training cost.
- The customers (frontier labs, regulated deployers) have both budget and risk model.

#pause

Making the business case requires _writing it down_. Per-widget: name the threat closed, the alternative being compared against, the lift to ship.

#pause

That is what the document is.

== What to do this weekend

If you came here to build, the hackathon-shaped subset:

#pause

- *Reproduce a BoxArena entry.* Pick a runtime, write the harness, run the five surfaces, publish the leaderboard row.
- *Spec a tiny piece of the OCI ABI in Lean or Rocq.* Even ten syscalls is useful.
- *Toy verified network tap in `Cryptol` or `SymbiYosys`.* P1, P2, P6 only. Stub the SerDes.
- *Measure $k$ on one spec shape.* Pick context-window allocation. Pick one model. Publish the distribution.
- *Find a soundness bug in Agda or Lean.* Submit it to the Arena.

== What to do over the next year

#pause

- If you're a *PL/FM researcher* looking for an AI-safety entry point: control protocols as a process calculus, or the verified OCI runtime.
- If you're an *ML person* worried about agentic deployment: BoxArena, sampler verification, context-window integrity.
- If you're *funding-shaped*: pay for the spec-elicitation work. It is the bottleneck the document points at.

#pause

The website is the live menu: #link("https://tractable.for-all.dev")[tractable.for-all.dev]. The tags are layer × adversary × category. Filter to your shape.

== Summary

#pause

- AI safety has an FM-shaped half nobody is staffing.
- The widgets are scoped. The principles are stable. The funding case inverts in this domain.
- 17 entries. Pick one.

#pause

#align(center)[
  #text(size: 32pt)[Questions?]

  #v(0.5em)

  #link("https://tractable.for-all.dev")[tractable.for-all.dev] \
  quinn\@for-all.dev
]

== Backup: the full problem list

*Enablers:* adversarial robustness of FM, spec elicitation, neuralese governance, AI control via PCC.

*Widgets, by layer:*

- L1 (harness): verified input parsers, sampler verification, context-window integrity, capability accumulation, agent weird machines, loop termination, audit log integrity.
- L2 (framework): weight integrity (also L1/L4).
- L3 (orchestration): OCI runtime hardening, scheduler co-tenancy, edge policy verification, verified network tap.
- L4 (firmware): seL4 native GPU drivers.
- L5 (hardware): verified network tap (also L3).

== Backup: the FM toolchain

What gets used in the widgets above:

#pause

- *ITPs:* `Lean`, `Rocq`, `Isabelle/HOL`, `Agda`, `ACL2`.
- *Separation logic:* `Iris` and descendants.
- *HW verification:* `Cryptol`, `Kami`, `SymbiYosys`.
- *Model checking:* `TLA+`, `Apalache`, `Spin`.
- *Translation validation:* for kernel binaries against contracts.

#pause

The toolchain is not the bottleneck. The targets are.

== Backup: what's out of scope

#pause

- Proving the model itself. Different document.
- Scheduler optimization. Policy, not mechanism.
- Multimode fiber taps. Link budget does not admit passive splitting at high baud rates.
- Full `POSIX` proofs. API surface too large.
- Anything where the spec cannot factor cleanly from the implementation.
