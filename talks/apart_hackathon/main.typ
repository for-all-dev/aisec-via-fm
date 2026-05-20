#import "@preview/touying:0.7.3": *
#import themes.simple: *
#import "assets/figures.typ": stack-overview

#show: simple-theme.with(
  aspect-ratio: "16-9",
  footer: [Tractable Problems in AI Security via Formal Methods --- #link("https://tractable.for-all.dev")[tractable.for-all.dev] - Apart SPS Hackathon - Quinn Dougherty],
)

#set text(size: 22pt)

= Tractable Problems in AI Security via Formal Methods

== Forall R&D:

Guiding AI safety orgs through the formal methods explosion.

== What formal methods can and can't claim

#text(size: 18pt)[
#figure(
  image("assets/fm-gap.svg", width: 70%),
  caption: [After Evan Miyazono. FM closes the middle gap only.],
)

- *Elicitation gap* (left): is the spec the thing we actually wanted? Out of scope for the proof.
- *Verification gap* (middle): does the implementation meet the spec? This is what FM does.
- *Modeling gap* (right): does the proof's model of the hardware/OS/network match reality?
]

== The ML training and inference stack

#align(center, scale(170%, reflow: true, stack-overview()))

== The tractable problems

17 entries on the website. Two flavors:

#pause

- *Enablers* unbottleneck a class of downstream work. Examples: adversarial robustness of FM tools, neuralese governance, spec elicitation.
- *Widgets* are concrete, scoped deliverables. Examples: seL4 GPU drivers, OCI runtime hardening, verified network tap.

#pause

An enabler with many dependents should be addressed early. A widget contingent on an unsolved enabler should be sequenced accordingly.

== Deep dive: three widgets, two enablers

I'll spend a slide or two on each.

+ OCI runtime hardening
+ seL4-native GPU drivers
+ Verified network tap
+ Spec elicitation and validation
+ Interpretability and governance of neuralese proof stacks

== Widget 1: OCI runtime hardening

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

Lineage: `CLInc` (Bevier 1989, gates to apps), `seL4` (Klein 2009, microkernel functional correctness).

== Widget 2: GPU drivers native to kernels other than linux

Multi-tenant GPU workloads run on hypervisors whose TCB is orders of magnitude too large to verify, with a proprietary ring-0 driver from the vendor.

#pause

Candidates to host an ML-grade GPU stack:
- `seL4` --- most complete proof, no GPU support at all.
- `CertiKOS` --- verified concurrent OS kernel with hypervisor extensions; layered refinement methodology, multicore.
- `NOVA` (not really a kernel) --- partial proof covers concurrency and weak memory, host/guest split built in.

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

== Widget 3: Verified network tap

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

== Enabler 1: Spec elicitation and validation

Proofs are cheap. Specs are expensive. Every widget in this document terminates in a spec --- a verified sampler, a hardened runtime, an IAM policy --- and the spec is the part the proof oracle cannot write for you. Or rather, if it does, you have quietly handed over the thing you were trying to keep.

#pause

Two subproblems:
- *Elicitation.* Stakeholder intent into a formal artifact. Requirements engineering with kernels, not PMs, as the consumer.
- *Validation.* The spec you wrote vs. the spec you meant. A proof of the wrong $P$ launders a bug into a theorem.

#pause

Handles: property-based testing (`QuickCheck`), spec mining (Ammons 2002), differential specification --- two independently elicited specs, checked for agreement.

== Enabler 2: Interp and governance of neuralese proof stacks

Warning: this would be a bad problem to have. We do not _condone_ this problem.

The "proofs are cheap" world assumes a known, trusted, human-readable proof substrate: `Lean`, `Rocq`, `Verus`, `Z3`.

#pause

What if that assumption is violated? A proof oracle competent enough to make proofs free is also competent enough to write its own proof stack --- one where human interpretability is not a first-class feature.

#pause

Then spec elicitation runs against syntax nobody has ever seen, and proof checking runs in a kernel nobody has audited. The trusted base evaporates.

#pause

The enabler: keep the proof substrate inside what humans can read, audit, and govern. Otherwise every other widget in this document is built on opaque foundations.

== What to do this weekend

If you came here to build, some hackathon-shaped ideas:

#pause

- *Reproduce a BoxArena entry.* Pick a runtime, write the harness, run the five surfaces, publish the leaderboard row.
- *Spec a tiny piece of the OCI ABI in Lean or Rocq.* Even ten syscalls is useful.
- *Toy verified network tap in `Cryptol` or `SymbiYosys`.* P1, P2, P6 only. Stub the SerDes.
- *Try differential specification.* Pick a small library (parser, queue, token bucket). Elicit two independent specs from two collaborators. Diff them.
- *Sketch a proof-stack interp bench.* What would it take to audit a proof kernel you didn't design? Pick one tactic, write the inspector.

== What to do over the next year

#pause

- If you're a *PL/FM researcher* looking for an AI-safety entry point: control protocols as a process calculus, or the verified OCI runtime.
- If you're an *ML person* worried about agentic deployment: BoxArena, sampler verification, context-window integrity.
- If you're *funding-shaped*: pay for the spec-elicitation work. It is the bottleneck the document points at.

#pause

The website is the live menu: #link("https://tractable.for-all.dev")[tractable.for-all.dev]. The tags are layer × adversary × category. Filter to your shape.

#pause

#align(center)[
  #text(size: 32pt)[Questions?]

  #v(0.5em)

  #link("https://tractable.for-all.dev")[tractable.for-all.dev] \
  quinn\@for-all.dev
]
