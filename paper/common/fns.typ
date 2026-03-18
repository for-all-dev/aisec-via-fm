// Shared utility functions and constants for the paper.

// Injected at compile time via --input flags in the Makefile.
#let git-commit = sys.inputs.at("commit", default: "dev")

#let paper_title = [Tractable Problems in AI Security via Formal Methods]

#let paper_abstract = [#lorem(80)]

/// Renders a styled layer tag label, used to associate tractable problems with
/// ML stack layers on the website.
#let layer-tag(name) = box(
  fill: rgb("#e8f0fe"),
  stroke: rgb("#4a90d9"),
  radius: 3pt,
  inset: (x: 4pt, y: 2pt),
  text(size: 7pt, fill: rgb("#1a56db"), name),
)
