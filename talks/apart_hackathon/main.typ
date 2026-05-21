#import "@preview/touying:0.7.3": *
#import themes.simple: *
#import "assets/figures.typ": stack-overview

#show: simple-theme.with(
  aspect-ratio: "16-9",
  footer: [Tractable Problems in AI Security via Formal Methods --- #link("https://tractable.for-all.dev")[tractable.for-all.dev] - Apart SPS Hackathon - Quinn Dougherty],
)

#set text(size: 22pt)

= Tractable Problems in AI Security via Formal Methods

= Forall R&D guides AI safety organizations through the formal methods explosion. And ships cyberhardening evals.

== Worldview

- Formal methods as a _boxing_ technology
- _Alignment_ via FM is out of scope

== What formal methods can and can't claim

#text(size: 18pt)[
#figure(
  image("assets/fm-gap.svg", width: 90%),
  caption: [After Evan Miyazono. Formal methods closes the middle gap only.],
)

- *Did we ask for the right thing?* (left): is the written spec what we actually wanted? Out of scope for the proof.
- *Does the code match the spec?* (middle): this is what formal methods does.
- *Does the spec's picture of the world match reality?* (right): the hardware, the OS, the network.
]

== The ML training and inference stack

#align(center, scale(170%, reflow: true, stack-overview()))

== The tractable problems

17 entries on the website. Two flavors:

- *Enablers* unblock a whole class of downstream work. Examples: making proof tools robust against adversaries, keeping specs human-readable, spec elicitation & validation.
- *Widgets* are concrete, scoped deliverables. Examples: GPU drivers for verified kernels, container runtime hardening, the network tap.

== In the talk: three widgets, two enablers

A slide or two on each.

+ Hardening the container runtime
+ GPU drivers for verified kernels
+ A verified network tap
+ Spec elicitation and validation
+ Keeping proofs human-readable

= Widget 1: hardening the container runtime

The standard container runtime was never designed to resist an attacker _inside_ the container.

#pause

When the workload is an AI agent that writes and runs its own code, "process isolation" is not a security boundary.

#pause

Empirical companion: BoxArena. Fix the attacker, vary the runtime, see what gets out.

== BoxArena: early leaderboard

#figure(
  image("assets/boxarena-leaderboard.png", width: 85%),
  caption: [Live at #link("https://box-arena.vercel.app")[box-arena.vercel.app].],
)

== The verified version

Three pieces:

#pause

- A precise description of which kernel calls a hardened container actually uses (about 80, not 350+).
- A statement of the confinement policy (no root, read-only filesystem, no new privileges).
- A proof that the runtime preserves the policy from every state it can reach.

= Widget 2: GPU drivers for verified kernels

GPU workloads today run on a stack whose trusted code base is far too large to verify, plus a closed driver from the vendor.

#pause

There are verified kernels that could host a better stack (seL4, CertiKOS). None of them have GPU support.

#pause

The methodology is settled. The blocker is that *no GPU vendor publishes a machine-readable description of their hardware*.

== The actual scope

Pick the smallest useful target: command submission for one open-source GPU stack.

#pause

Property to prove: _no sequence of guest commands causes the driver to read or write memory outside the guest's declared region._

#pause

Two stopping points: verified against a stubbed hardware model (shippable as reference), or against a model co-developed with the vendor (the research contribution).

= Widget 3: a verified network tap

The threat: on a GPU cluster, the network controller itself is part of what we worry about being compromised. Its own logs are not evidence.

The artifact: a tap on the fiber with a capture path proven correct (cheap at the cluster edge, modestly expensive between storage nodes).

#figure(
  image("assets/cankaya-tap-placement.png", width: 78%),
    caption: [From #link("https://nacicankaya.substack.com/p/research-note-the-fundamentals-and")[Cankaya 2026]. Numbered tap points: edge uplink, inter-pod, storage fabric, inter-rack.],
)

== What the tap must prove

#text(size: 18pt)[
$ square ( "live_in"(p) &-> diamond_(<= D) "live_out"(p) ) & quad "(P1) packets that come in go out" \
  square ( "live_out"(p) &-> diamond.filled "live_in"(p) ) & quad "(P2) packets that go out came in" \
  square ( "live_in"(p) &-> diamond_(<= D') "mon"("image"(p)) ) & quad "(P3) every packet is mirrored" \
  square ( "mon"(r) &-> diamond.filled (exists p. "live_in"(p) and "image"(p) = r) ) & quad "(P4) every mirror really happened" \
  square ( "live_out"(p) &-> not "depends-on"(p, "mon-input") ) & quad "(P5) the monitor can't influence traffic" \
  square ( "fail" &-> square ( "live_in"(p) -> diamond_(<= D) "live_out"(p) ) ) & quad "(P6) on failure, fall back to a wire" $
]

#pause

P5 is what defeats a colluding monitor. P6 is what makes it deployable in production.

= Enabler 1: spec elicitation and validation

*Proofs are getting cheap*. #pause *Specs are not.* #pause You probably want lots of human-in-the-loop on specs, even in the long term, even when human is out of the loop on code and proofs.

#pause

Two subproblems:
- *Elicitation.* Turning what stakeholders want into a precise artifact.
- *Validation.* The spec you wrote vs. the spec you meant. A proof of the wrong thing turns a bug into a theorem.

= Enabler 2: keeping specs human-readable

*To be clear: this would be a bad problem to have. We do not condone causing this problem*

#pause

If you prompt Opus 5 to write the box to train and deploy Opus 6 in, what are the odds that it goes with Lean or Isabelle or some human-provenance'd proof stack, when its capable of making its own proofstack? #pause This *neuralese proofstack* may have real security or performance upside, but then you see the problem when you try to keep the human in the loop on specification...

= Hackathon-shaped projects

- *Expand on BoxArena.* Vibecode a runtime, run the attack surfaces, publish the result.
- *Specify ten kernel calls in a proof assistant.* A subset of a kernel is useful, if you write up what you learned well.
- *Sketch a toy network tap.* Just the forwarding properties. Stub the hardware.
- *Try differential specs.* Pick a small library, have two people write specs independently, diff them.
- *Audit a proof checker you didn't write.* Pick one tactic, write the inspector.

= Tractable Problems in AI Security via Formal Methods

#align(center)[
  #text(size: 32pt)[Questions?]

  #v(0.5em)

  #link("https://tractable.for-all.dev")[tractable.for-all.dev] \
  quinn\@for-all.dev
]
