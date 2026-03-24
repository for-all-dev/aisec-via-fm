// Shared utility functions and constants for the paper.

// Injected at compile time via --input flags in the Makefile.
#let git-commit = sys.inputs.at("commit", default: "dev")

#let paper_title = [Tractable Problems in AI Security via Formal Methods]

#let paper_abstract = [Secure program synthesis is popping off in 2026 @regehr2026zerodof @kleppmann2025fvmainstream @vonhippel2025securesynthesis, which will be great for our overall cyber resilience. However, its not obvious that it will actually be applied to AI security in real life. To seize this opportunity, we need to map out the relevant layers in the current ML inference and training stack and figure out what widgets can or ought be formal methods opportunities.]

/// Renders a styled layer tag label, used to associate tractable problems with
/// ML stack layers on the website.
#let layer-tag(name) = box(
  fill: rgb("#e8f0fe"),
  stroke: rgb("#4a90d9"),
  radius: 3pt,
  inset: (x: 4pt, y: 2pt),
  text(size: 7pt, fill: rgb("#1a56db"), name),
)
