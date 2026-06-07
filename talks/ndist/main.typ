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

== GPU drivers for verified kernels

TODO

= Onwards

== How you can help

/ More contributions: Come aboard! More room for authors. Or, if you want to be low-key, comment on the website's native comments feature.

/ Tokens: Ask claude to implement one of the project sketches on `/problems`. Let us know how it goes.

/ Podcasts: What podcasts should we go on to discuss this? Get us invited.

/ I'm easy to find: `quinn@for-all.dev`
