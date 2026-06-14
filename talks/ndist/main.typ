#import "@preview/diatypst:0.9.3": *
#import "./assets/figures.typ": stack-overview

#show: slides.with(
  title: "Tractable Problems in AI Security via Formal Methods", // Required
  subtitle: "A sane way to burn a few postdoc-years",
  date: "06.17.2026",
  authors: ("Quinn Dougherty"),
  footer-subtitle: "https://tractable.for-all.dev",

  // Optional (for more see docs at https://mdwm.org/diatypst/)
  ratio: 16/9,
  layout: "medium",
  title-color: red.darken(60%),
  toc: true,
  // theme: "full"
)

= The strategic landscape

== _Let us treat ML training and inference with the seriousness of airplanes_
\


/ Authors: Quinn Dougherty, Max von Hippel, Gregory Malecha, Nora Ammann

We mostly write about model weight confidentiality and integrity, but other notions of AI security are in scope. Not the biggest possible tent, but more than two invariants.

== The White House

#figure(image("assets/whitehouse.png"), caption: "Demands hardened critical infrastructure, doesn't say how.")

== RAND

#figure(image("assets/rand.png"), caption: "Expert survey, human and simulated/silicon")

== ARIA

TODO

== Anthropic

#scale(80%, figure(image("assets/anthropic.png"), caption: text[See _Leveling up across the board_ at https://www.anthropic.com/responsible-scaling-policy/roadmap]))

== Speed

#scale(90%, figure(image("assets/gru.jpg"), caption: "This is technically a violation of the meme format."))

= The stack

== 5 layers

#figure(align(center, scale(110%, reflow: true, stack-overview())), caption: "The path of a prompt from the enduser to the chip's circuits")

= Tractable Problems

== Hardening protocol boundaries

TODO

== Hardening OCI runtime

TODO

== Device drivers for verified kernels

The kernel can be verified; the driver underneath it usually can't.

/ Status quo: Multi-tenant GPU isolation rides on million-line hypervisor TCBs, with a proprietary ring-0 GPU driver as the single point of compromise.
/ The good news: `seL4`, `NOVA`, `seKVM`, and AWS Nitro verify a minimal core and push drivers out to deprivileged user-mode --- the right architecture.
/ The real blocker: Not the proof, the spec. Driver proofs are a settled methodology (a verified ZynqMP DMA engine exists); what's missing is a machine-checkable model of the GPU's command / DMA / IOMMU surface. Vendors model the *ISA* --- Arm, RISC-V, even AMD's shaders --- not the device.
/ The widget: Specify one open GPU stack's command-submission ring (`NVK`/`Nouveau`) in `Rocq`/`Lean`; prove no guest command can drive a DMA or IOMMU mapping outside its region. Stub the hardware model first (reference), then co-develop a real one (research).

= Onwards

== How you can help

/ More contributions: Come aboard! More room for authors. Or, if you want to be low-key, comment on the website's native comments feature.

/ Tokens: Ask claude to implement one of the project sketches on `/problems`. Let us know how it goes.

/ Podcasts: What podcasts should we go on to discuss this? Get us invited.

/ I'm easy to find: `quinn@for-all.dev`
