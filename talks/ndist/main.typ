#import "@preview/diatypst:0.9.3": *
#import "./assets/figures.typ": stack-overview

#show: slides.with(
  title: "Tractable Problems in AI Security via Formal Methods", // Required
  subtitle: "A sane way to burn a few postdoc-years",
    date: "06.17.2026",
  authors: ("Quinn Dougherty"),

  // Optional (for more see docs at https://mdwm.org/diatypst/)
  ratio: 16/9,
  layout: "medium",
  title-color: red.darken(60%),
  toc: true,
)

= The strategic landscape

== Let us treat ML training and inference with the seriousness we treat airplanes

== The White House

#figure(image("assets/whitehouse.png"), caption: "Demands hardened critical infrastructure, doesn't say how.")

== TODO: cite RAND

/ *Term*: Definition

== TODO: cite ARIA

== TODO: cite anthropic

= The stack

== 5 layers

#align(center, scale(110%, reflow: true, stack-overview()))
