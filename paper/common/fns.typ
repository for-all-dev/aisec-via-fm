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
  } else if cat == "widget" {
    (rgb("#d1fae5"), rgb("#059669"), rgb("#065f46"))
  } else {
    panic("Invalid problem category `" + str(cat) + "`. Expected one of: \"enabler\", \"widget\".")
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

#let _layer-meta = (
  "execution-harness":    (label: "Execution Harness",                sec: label("sec:execution-harness")),
  "software-framework":   (label: "Software & ML Framework",          sec: label("sec:software-framework")),
  "orchestration-cloud":  (label: "Orchestration & Cloud",            sec: label("sec:orchestration-cloud")),
  "firmware-lowlevel":    (label: "Firmware & Low-Level Systems",     sec: label("sec:firmware-lowlevel")),
  "hardware-supply-chain":(label: "Hardware & Physical Supply Chain", sec: label("sec:hardware-supply-chain")),
)

// _problem-meta is inferred from the problem files' comment headers.
// Each problem file must have:  // Tag: <id>  // Layers: <csv>  // Category: <cat>
// and a heading line:  == Title <sec:label>

#let _parse-problem-file(path) = {
  let src = read(path)
  let lines = src.split("\n")
  let tag = none
  let layers = ()
  let category = none
  let heading-label = none
  let heading-title = none
  for line in lines {
    if line.starts-with("// Tag: ") {
      tag = line.slice(8).trim()
    } else if line.starts-with("// Layers: ") {
      layers = line.slice(11).split(",").map(s => s.trim())
    } else if line.starts-with("// Category: ") {
      category = line.slice(13).trim()
    } else if line.starts-with("== ") {
      // Parse "== Some Title <sec:foo-bar>"
      let rest = line.slice(3)
      let angle-start = rest.position("<")
      let angle-end = rest.position(">")
      if angle-start != none and angle-end != none {
        heading-title = rest.slice(0, angle-start).trim()
        heading-label = rest.slice(angle-start + 1, angle-end)
      }
    }
  }
  (tag, (label: heading-title, sec: label(heading-label), layers: layers, category: category))
}

// Parse problems/main.typ to get the include list, then read each file.
#let _problems-main-src = read("../problems/main.typ")
#let _problem-files = {
  let files = ()
  for line in _problems-main-src.split("\n") {
    if line.starts-with("#include \"") {
      let fname = line.slice(10, line.len() - 1)  // strip #include " and trailing "
      files.push(fname)
    }
  }
  files
}

#let _problem-meta = {
  let meta = (:)
  for fname in _problem-files {
    let (tag, entry) = _parse-problem-file("../problems/" + fname)
    meta.insert(tag, entry)
  }
  meta
}

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
