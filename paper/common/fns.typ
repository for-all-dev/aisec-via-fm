// Shared utility functions and constants for the paper.

// Injected at compile time via --input flags in the Makefile.
#let git-commit = sys.inputs.at("commit", default: "dev")

#let authors = json("authors.json")
#let _texts = json("tooltips.json")

#let paper_title = [#_texts.title]

#let paper_abstract = [Secure program synthesis is popping off in 2026 @regehr2026zerodof @kleppmann2025fvmainstream @vonhippel2025securesynthesis, which will be great for our overall cyber resilience. However, its not obvious that it will actually be applied to AI security in real life. To seize this opportunity, we need to map out the relevant layers in the current ML inference and training stack and figure out what widgets represent formal methods opportunities.]

/// Renders a styled layer tag label, used to associate tractable problems with
/// ML stack layers on the website.
#let layer-tag(name) = box(
  fill: rgb("#e8f0fe"),
  stroke: rgb("#4a90d9"),
  radius: 3pt,
  inset: (x: 4pt, y: 2pt),
  text(size: 7pt, fill: rgb("#1a56db"), name),
)

/// Renders an adversary tag. Used both on layer sections ("invites") and on
/// problem sections ("blocks"). Red-ish because adversaries are threats.
#let adversary-tag(name) = box(
  fill: rgb("#fee2e2"),
  stroke: rgb("#dc2626"),
  radius: 3pt,
  inset: (x: 4pt, y: 2pt),
  text(size: 7pt, fill: rgb("#991b1b"), name),
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

// ── Adversary registry: loaded from tooltips.json so paper and website share a source of truth ──

#let _adversary-meta = {
  let m = (:)
  for (aid, v) in _texts.adversaries {
    m.insert(aid, (label: v.label, desc: v.desc))
  }
  m
}

// ── Digraph: many-to-many mapping between stack layers and problems ──

#let _layer-meta = (
  "execution-harness":    (label: "Execution Harness",                sec: label("sec:execution-harness")),
  "software-framework":   (label: "Software & ML Framework",          sec: label("sec:software-framework")),
  "orchestration-cloud":  (label: "Orchestration & Cloud",            sec: label("sec:orchestration-cloud")),
  "firmware-lowlevel":    (label: "Firmware & Low-Level Systems",     sec: label("sec:firmware-lowlevel")),
  "hardware-supply-chain":(label: "Hardware & Physical Supply Chain", sec: label("sec:hardware-supply-chain")),
)

// _layer-invites is parsed from each stack file's `// Invites: adv1, adv2` header.
#let _parse-invites(path) = {
  let src = read(path)
  for line in src.split("\n") {
    if line.starts-with("// Invites: ") {
      return line.slice(12).split(",").map(s => s.trim())
    }
  }
  ()
}

#let _layer-invites = (
  "execution-harness":     _parse-invites("../stack/execution-harness.typ"),
  "software-framework":    _parse-invites("../stack/software-framework.typ"),
  "orchestration-cloud":   _parse-invites("../stack/orchestration-cloud.typ"),
  "firmware-lowlevel":     _parse-invites("../stack/firmware-lowlevel.typ"),
  "hardware-supply-chain": _parse-invites("../stack/hardware-supply-chain.typ"),
)

// _problem-meta is inferred from the problem files' comment headers.
// Each problem file must have:  // Tag: <id>  // Layers: <csv>  // Category: <cat>
// and a heading line:  == Title <sec:label>

#let _parse-problem-file(path) = {
  let src = read(path)
  let lines = src.split("\n")
  let tag = none
  let layers = ()
  let adversaries = ()
  let category = none
  let heading-label = none
  let heading-title = none
  for line in lines {
    if line.starts-with("// Tag: ") {
      tag = line.slice(8).trim()
    } else if line.starts-with("// Layers: ") {
      layers = line.slice(11).split(",").map(s => s.trim())
    } else if line.starts-with("// Adversaries: ") {
      adversaries = line.slice(16).split(",").map(s => s.trim())
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
  (tag, (label: heading-title, sec: label(heading-label), layers: layers, adversaries: adversaries, category: category))
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
/// Enablers are amber, widgets are green (matching problem-category styles).
#let problem-badge(pid) = {
  let pm = _problem-meta.at(pid)
  let (fill-color, stroke-color, text-color) = if pm.category == "enabler" {
    (rgb("#fef3c7"), rgb("#d97706"), rgb("#92400e"))
  } else {
    (rgb("#d1fae5"), rgb("#059669"), rgb("#065f46"))
  }
  link(pm.sec, box(
    fill: fill-color,
    stroke: stroke-color,
    radius: 3pt,
    inset: (x: 4pt, y: 2pt),
    text(size: 7pt, fill: text-color, pm.label),
  ))
}

/// Render a clickable badge linking to a stack layer section.
#let layer-badge(lid) = {
  let lm = _layer-meta.at(lid)
  link(lm.sec, layer-tag(lm.label))
}

/// Render an adversary badge. Not linked (no per-adversary section yet);
/// the taxonomy lives in tooltips.json and surfaces on the website.
#let adversary-badge(aid) = {
  let am = _adversary-meta.at(aid)
  adversary-tag(am.label)
}

/// Place at the top of a stack-layer section to list related problems.
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
/// Takes the problem's tag and looks up the layers from _problem-meta,
/// so the `// Layers:` comment header is the single source of truth.
#let related-layers(problem-tag) = {
  let pm = _problem-meta.at(problem-tag)
  let ids = pm.layers
  if ids.len() > 0 {
    block(
      above: 4pt,
      below: 8pt,
      [_Stack layers:_ #ids.map(lid => layer-badge(lid)).join([ ])]
    )
  }
}

/// Place at the top of a problem section to list the adversaries it blocks.
/// Reads from the problem's `// Adversaries:` header.
#let adversaries-blocked(problem-tag) = {
  let pm = _problem-meta.at(problem-tag)
  let ids = pm.adversaries
  if ids.len() > 0 {
    block(
      above: 2pt,
      below: 8pt,
      [_Blocks:_ #ids.map(aid => adversary-badge(aid)).join([ ])]
    )
  }
}

/// Place at the top of a stack-layer section to list the adversaries it
/// invites. Reads from the layer file's `// Invites:` header.
#let adversaries-invited(layer-id) = {
  let ids = _layer-invites.at(layer-id, default: ())
  if ids.len() > 0 {
    block(
      above: 2pt,
      below: 4pt,
      [_Invites:_ #ids.map(aid => adversary-badge(aid)).join([ ])]
    )
  }
}
