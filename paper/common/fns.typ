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

/// Renders a styled problem-category tag, used to distinguish enabler problems
/// (broad unbottleneckers) from widget problems (concrete deliverables).
/// Valid values: "enabler", "widget"
#let problem-category(cat) = {
  let (fill-color, stroke-color, text-color) = if cat == "enabler" {
    (rgb("#fef3c7"), rgb("#d97706"), rgb("#92400e"))
  } else {
    (rgb("#d1fae5"), rgb("#059669"), rgb("#065f46"))
  }
  box(
    fill: fill-color,
    stroke: stroke-color,
    radius: 3pt,
    inset: (x: 4pt, y: 2pt),
    text(size: 7pt, fill: text-color, cat),
  )
}

// ── Digraph: many-to-many mapping between stack layers and problems ──

// The canonical mapping lives in digraph.json for machine readability.
// Below we duplicate it as Typst dictionaries so the PDF gets clickable
// cross-references without a build-time JSON-parse step.

#let _layer-meta = (
  "execution-harness":    (label: "Execution Harness",                sec: label("sec:execution-harness")),
  "software-framework":   (label: "Software & ML Framework",          sec: label("sec:software-framework")),
  "orchestration-cloud":  (label: "Orchestration & Cloud",            sec: label("sec:orchestration-cloud")),
  "firmware-lowlevel":    (label: "Firmware & Low-Level Systems",     sec: label("sec:firmware-lowlevel")),
  "hardware-supply-chain":(label: "Hardware & Physical Supply Chain", sec: label("sec:hardware-supply-chain")),
)

#let _problem-meta = (
  "adversarial-robustness-fm":      (label: "Adversarial Robustness of FM",      sec: label("sec:adversarial-robustness"),   layers: ("software-framework", "execution-harness")),
  "ai-control-proof-carrying-code": (label: "AI Control via Proof-Carrying Code", sec: label("sec:proof-carrying-code"),      layers: ("execution-harness", "software-framework", "orchestration-cloud")),
  "audit-log-integrity":            (label: "Audit Log Integrity",                sec: label("sec:audit-log-integrity"),      layers: ("execution-harness", "orchestration-cloud")),
  "capability-accumulation":        (label: "Capability Accumulation",            sec: label("sec:capability-accumulation"),  layers: ("execution-harness",)),
  "context-window-integrity":       (label: "Context Window Integrity",           sec: label("sec:context-window-integrity"), layers: ("execution-harness",)),
  "edge-policy-verification":       (label: "Edge Policy Verification",           sec: label("sec:edge-policy"),              layers: ("execution-harness", "orchestration-cloud")),
  "network-tap-fpga":               (label: "Network Tap FPGA Spec",             sec: label("sec:network-tap-fpga"),         layers: ("orchestration-cloud", "hardware-supply-chain")),
  "neuralese-gov":                  (label: "Neuralese Governance",               sec: label("sec:neuralese-gov"),            layers: ("execution-harness", "software-framework", "orchestration-cloud")),
  "oci-runtime-hardening":          (label: "OCI Runtime Hardening",              sec: label("sec:oci-hardening"),            layers: ("orchestration-cloud", "execution-harness")),
  "sampler-verification":           (label: "Sampler Verification",               sec: label("sec:sampler-verification"),     layers: ("software-framework", "execution-harness")),
  "scheduler-cotenancy":            (label: "Scheduler Co-Tenancy Isolation",     sec: label("sec:scheduler-cotenancy"),      layers: ("orchestration-cloud",)),
  "sel4-gpu-drivers":               (label: "seL4 Native GPU Drivers",            sec: label("sec:sel4-gpu"),                 layers: ("firmware-lowlevel", "hardware-supply-chain")),
  "verified-input-parsers":         (label: "Verified Input Parsers",             sec: label("sec:verified-input-parsers"),   layers: ("execution-harness", "software-framework")),
  "weight-integrity":               (label: "Weight Integrity",                   sec: label("sec:weight-integrity"),         layers: ("execution-harness", "software-framework", "firmware-lowlevel")),
)

/// Given a layer id, return the list of problem ids that touch it.
#let _problems-for-layer(layer-id) = {
  let result = ()
  for (pid, pm) in _problem-meta {
    if layer-id in pm.layers {
      result.push(pid)
    }
  }
  result
}

/// Render a clickable badge linking to a problem section.
#let problem-badge(pid) = {
  let pm = _problem-meta.at(pid)
  link(pm.sec, box(
    fill: rgb("#fef3c7"),
    stroke: rgb("#d97706"),
    radius: 3pt,
    inset: (x: 4pt, y: 2pt),
    text(size: 7pt, fill: rgb("#92400e"), pm.label),
  ))
}

/// Render a clickable badge linking to a stack layer section.
#let layer-badge(lid) = {
  let lm = _layer-meta.at(lid)
  link(lm.sec, layer-tag(lm.label))
}

/// Place at the end of a stack-layer section to list related problems.
#let related-problems(layer-id) = {
  let pids = _problems-for-layer(layer-id)
  if pids.len() > 0 {
    block(
      above: 8pt,
      below: 4pt,
      [_Related problems:_ #pids.map(pid => problem-badge(pid)).join([ ])]
    )
  }
}

/// Place at the top of a problem section to list related layers.
#let related-layers(..layer-ids) = {
  let ids = layer-ids.pos()
  if ids.len() > 0 {
    block(
      above: 4pt,
      below: 8pt,
      [_Stack layers:_ #ids.map(lid => layer-badge(lid)).join([ ])]
    )
  }
}
