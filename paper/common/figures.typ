// CeTZ-based diagrams shared across the paper.
// Keep each figure pure: no side effects, no global state. Each function
// returns content suitable for use inside #figure(...).

#import "@preview/cetz:0.5.2" as cetz: canvas, draw

// In HTML export the cetz `canvas` block becomes an empty <div>, because
// the HTML target can't render typst frames natively. `html.frame(...)`
// embeds the content as inline SVG. In paged (PDF) export, plain canvas
// content already renders, so we pass it through unchanged.
//
// The target is signalled by `--input target=html` on the compile command;
// this is set by the website's NodeCompiler invocation and absent for
// `typst compile`/`typst watch`, which defaults to paged.
#let _maybe-frame(c) = if sys.inputs.at("target", default: "paged") == "html" {
  html.frame(c)
} else {
  c
}

// ── Color palette (shared across diagrams) ────────────────────────
#let _layer-fill  = rgb("#eef2ff")
#let _layer-stroke = rgb("#4f46e5")
#let _adv-fill    = rgb("#fee2e2")
#let _adv-stroke  = rgb("#dc2626")
#let _ok-fill     = rgb("#d1fae5")
#let _ok-stroke   = rgb("#059669")
#let _warn-fill   = rgb("#fef3c7")
#let _warn-stroke = rgb("#d97706")
#let _muted       = rgb("#64748b")

// ── Figure 1: The five-layer stack with adversaries ──────────────
#let stack-overview() = _maybe-frame(canvas({
  import draw: *
  set-style(content: (padding: 2pt))

  // Layers, top-down (drawn bottom-up so y-axis stays natural)
  let layers = (
    ("Execution Harness",            "inference servers · sandboxes · API gateways",         4),
    ("Software & ML Framework",      "compilers · frameworks · dep. supply chain",            3),
    ("Orchestration & Cloud",        "schedulers · network fabric · IAM · model registries",  2),
    ("Firmware & Low-Level Systems", "hypervisors · GPU drivers · boot chain · BMC",          1),
    ("Hardware & Physical Supply",   "RTL · EDA toolchain · HBM interposer · fab",            0),
  )

  let lx = 0
  let lw = 9
  let lh = 1.1

  for (name, sub, y) in layers {
    rect((lx, y * lh), (lx + lw, y * lh + lh),
      fill: _layer-fill, stroke: _layer-stroke + 0.6pt, radius: 2pt)
    content((lx + 0.15, y * lh + lh - 0.18),
      anchor: "north-west",
      text(size: 8.5pt, weight: "bold", name))
    content((lx + 0.15, y * lh + 0.16),
      anchor: "south-west",
      text(size: 6.5pt, fill: _muted, sub))
  }

  // Right-hand bracket: "what's at risk"
  let total-h = 5 * lh
  line((lx + lw + 0.25, 0), (lx + lw + 0.45, 0),
       (lx + lw + 0.45, total-h), (lx + lw + 0.25, total-h),
       stroke: _muted + 0.5pt)
  content((lx + lw + 0.55, total-h / 2),
    anchor: "west",
    text(size: 6.5pt, fill: _muted)[
      #set par(leading: 0.4em)
      prompts \ + responses \ \
      model weights \ + training data \ \
      silicon \ integrity
    ])

  // Left-hand: adversaries pointing in
  let advs = (
    ("external-user",      4.5),
    ("malicious-model",    4.0),
    ("co-tenant",          3.0),
    ("supply-chain",       2.6),
    ("network-mitm",       2.0),
    ("rogue-insider",      1.4),
    ("physical-adversary", 0.4),
  )

  let ax = -2.8
  let aw = 2.0
  let ah = 0.34

  for (name, y) in advs {
    let cy = y * lh
    rect((ax, cy - ah/2), (ax + aw, cy + ah/2),
      fill: _adv-fill, stroke: _adv-stroke + 0.4pt, radius: 1.5pt)
    content((ax + aw/2, cy), anchor: "center",
      text(size: 6.5pt, fill: _adv-stroke, name))
    // arrow into the closest layer
    line((ax + aw + 0.05, cy), (lx - 0.05, cy),
      stroke: _adv-stroke + 0.4pt, mark: (end: ">"))
  }

  content((ax + aw/2, 5 * lh + 0.18),
    anchor: "south",
    text(size: 7pt, weight: "bold", fill: _adv-stroke, "adversaries"))
}))

// ── Figure 2: Compilation pipeline with injection points ──────────
#let compile-pipeline() = _maybe-frame(canvas({
  import draw: *
  set-style(content: (padding: 2pt))

  let stages = (
    "PyTorch source",
    "torch.compile",
    "Triton IR",
    "LLVM IR",
    "PTX",
    "SASS",
  )

  let bw = 1.55
  let bh = 0.7
  let gap = 0.35

  for (i, s) in stages.enumerate() {
    let x = i * (bw + gap)
    rect((x, 0), (x + bw, bh),
      fill: _layer-fill, stroke: _layer-stroke + 0.6pt, radius: 2pt)
    content((x + bw/2, bh/2), anchor: "center",
      text(size: 7pt, weight: "bold", s))
    if i < stages.len() - 1 {
      line((x + bw + 0.03, bh/2), (x + bw + gap - 0.03, bh/2),
        stroke: _layer-stroke + 0.5pt, mark: (end: ">"))
    }
  }

  // Injection points (red) hanging off each stage
  let injections = (
    (1, "fusion bias"),
    (2, "rewrite swap"),
    (3, "MLIR memory bug"),
    (4, "quant rounding"),
  )

  for (idx, label) in injections {
    let x = idx * (bw + gap) + bw/2
    line((x, -0.05), (x, -0.55),
      stroke: _adv-stroke + 0.4pt, mark: (start: ">"))
    content((x, -0.7), anchor: "north",
      text(size: 6pt, fill: _adv-stroke, label))
  }

  // What we see vs. what runs
  content(((stages.len() - 1) * (bw + gap) + bw + 0.45, bh/2),
    anchor: "west",
    text(size: 7pt, weight: "bold", fill: _ok-stroke, "→ silicon"))

  content((-0.15, bh/2), anchor: "east",
    text(size: 7pt, weight: "bold", fill: _muted, "model"))

  // Trust gap callout
  content((((stages.len() - 1) * (bw + gap)) / 2 + bw/2, -1.3),
    anchor: "center",
    text(size: 6.5pt, fill: _muted, style: "italic",
      "Each stage rewrites the computation in ways the author never sees."))
}))

// ── Figure 3: Verified boot vs measured boot ──────────────────────
#let boot-chain() = _maybe-frame(canvas({
  import draw: *
  set-style(content: (padding: 2pt))

  let stages = (
    "Hardware RoT",
    "Firmware",
    "Bootloader",
    "OS Kernel",
  )
  let bw = 1.65
  let bh = 0.55
  let gap = 0.25

  // Top row: verified boot (halt-on-failure)
  let y-top = 1.4
  content((-0.15, y-top + bh/2), anchor: "east",
    text(size: 7pt, weight: "bold", "Verified boot"))
  for (i, s) in stages.enumerate() {
    let x = i * (bw + gap)
    rect((x, y-top), (x + bw, y-top + bh),
      fill: _layer-fill, stroke: _layer-stroke + 0.6pt, radius: 2pt)
    content((x + bw/2, y-top + bh/2), anchor: "center",
      text(size: 7pt, s))
    if i < stages.len() - 1 {
      line((x + bw + 0.02, y-top + bh/2), (x + bw + gap - 0.02, y-top + bh/2),
        stroke: _layer-stroke + 0.5pt, mark: (end: ">"))
    }
  }
  content((stages.len() * (bw + gap) + 0.1, y-top + bh/2),
    anchor: "west",
    text(size: 6.5pt, fill: _muted, style: "italic",
      "halts on bad signature; \n trusts the sig DB"))

  // Bottom row: measured boot (record-and-attest)
  let y-bot = 0
  content((-0.15, y-bot + bh/2), anchor: "east",
    text(size: 7pt, weight: "bold", "Measured boot"))
  for (i, s) in stages.enumerate() {
    let x = i * (bw + gap)
    rect((x, y-bot), (x + bw, y-bot + bh),
      fill: _layer-fill, stroke: _layer-stroke + 0.6pt, radius: 2pt)
    content((x + bw/2, y-bot + bh/2), anchor: "center",
      text(size: 7pt, s))
    if i < stages.len() - 1 {
      line((x + bw + 0.02, y-bot + bh/2), (x + bw + gap - 0.02, y-bot + bh/2),
        stroke: _layer-stroke + 0.5pt, mark: (end: ">"))
    }
    // hash measurement arrow down
    line((x + bw/2, y-bot - 0.05), (x + bw/2, y-bot - 0.55),
      stroke: _ok-stroke + 0.4pt, mark: (end: ">"))
  }

  // TPM / attestation log
  let tpm-x = (stages.len() * (bw + gap)) / 2 - bw/2 - gap/2
  rect((tpm-x - 0.6, y-bot - 1.2), (tpm-x + (bw + gap) * (stages.len() - 1) + bw + 0.6, y-bot - 0.55),
    fill: _ok-fill, stroke: _ok-stroke + 0.6pt, radius: 2pt)
  content((tpm-x + ((bw + gap) * (stages.len() - 1) + bw) / 2 - 0.3, y-bot - 0.85),
    anchor: "center",
    text(size: 7pt, weight: "bold", fill: _ok-stroke,
      "TPM / attestation log → external policy plane"))

  content((stages.len() * (bw + gap) + 0.1, y-bot + bh/2),
    anchor: "west",
    text(size: 6.5pt, fill: _muted, style: "italic",
      "records everything; \n policy lives elsewhere"))
}))

// ── Figure 4: Layer × adversary incidence matrix ──────────────────
// Uses the parsed `// Invites:` headers from each stack layer.
#let _layer-order = (
  ("execution-harness",    "Execution Harness"),
  ("software-framework",   "Software & ML Framework"),
  ("orchestration-cloud",  "Orchestration & Cloud"),
  ("firmware-lowlevel",    "Firmware & Low-Level"),
  ("hardware-supply-chain","Hardware & Physical"),
)

#let _adv-order = (
  "external-user",
  "malicious-model",
  "co-tenant",
  "supply-chain",
  "network-mitm",
  "rogue-insider",
  "physical-adversary",
)

#let _adv-short = (
  "external-user":      "ext-user",
  "malicious-model":    "mal-model",
  "co-tenant":          "co-tenant",
  "supply-chain":       "sup-chain",
  "network-mitm":       "net-mitm",
  "rogue-insider":      "insider",
  "physical-adversary": "physical",
)

// ── Figure 5: Problem × layer incidence matrix ────────────────────
// Columns: layers; rows: problems. Cell colored by category (enabler vs widget).
#let problem-layer-matrix(problem-meta, problem-files) = _maybe-frame(canvas({
  import draw: *
  set-style(content: (padding: 1.5pt))

  // Use file include order so the matrix matches the section ordering.
  let pids = ()
  for fname in problem-files {
    // strip ".typ"
    let stem = fname.slice(0, fname.len() - 4)
    // tag id == file stem in this repo's convention, but be defensive: find a
    // problem whose section label matches the stem if exact key lookup fails.
    if stem in problem-meta {
      pids.push(stem)
    } else {
      for (pid, pm) in problem-meta {
        if str(pm.sec) == "sec:" + stem {
          pids.push(pid)
          break
        }
      }
    }
  }
  // Fallback: if parsing didn't recover everything, append leftovers.
  for (pid, _) in problem-meta {
    if pid not in pids {
      pids.push(pid)
    }
  }

  let cw = 1.4  // column (layer) width
  let rh = 0.4  // row (problem) height
  let label-w = 4.6 // problem label column

  // Column headers (layers, abbreviated)
  let layer-abbrev = (
    "execution-harness":     "harness",
    "software-framework":    "framework",
    "orchestration-cloud":   "orch.",
    "firmware-lowlevel":     "firmware",
    "hardware-supply-chain": "hardware",
  )

  let n-layers = _layer-order.len()
  for (ci, (lid, _)) in _layer-order.enumerate() {
    content((label-w + ci * cw + cw/2, pids.len() * rh + 0.15),
      anchor: "south",
      text(size: 6.5pt, fill: _layer-stroke, layer-abbrev.at(lid)))
  }

  // Rows
  for (ri, pid) in pids.enumerate() {
    let pm = problem-meta.at(pid)
    let y = (pids.len() - 1 - ri) * rh
    // problem label
    content((label-w - 0.1, y + rh/2), anchor: "east",
      text(size: 6.5pt, pm.label))
    // category swatch on the left
    let (sw-f, sw-s) = if pm.category == "enabler" {
      (_warn-fill, _warn-stroke)
    } else {
      (_ok-fill, _ok-stroke)
    }
    rect((label-w - 0.06, y + 0.08), (label-w - 0.01, y + rh - 0.08),
      fill: sw-f, stroke: sw-s + 0.4pt)
    // layer cells
    for (ci, (lid, _)) in _layer-order.enumerate() {
      let x = label-w + ci * cw
      let hit = lid in pm.layers
      rect((x + 0.04, y + 0.04), (x + cw - 0.04, y + rh - 0.04),
        fill: if hit { sw-f } else { rgb("#f8fafc") },
        stroke: if hit { sw-s + 0.4pt } else { rgb("#e2e8f0") + 0.3pt })
      if hit {
        content((x + cw/2, y + rh/2), anchor: "center",
          text(size: 7pt, weight: "bold", fill: sw-s, "●"))
      }
    }
  }

  // Legend
  let leg-y = -0.7
  rect((label-w, leg-y), (label-w + 0.2, leg-y + 0.2),
    fill: _warn-fill, stroke: _warn-stroke + 0.4pt)
  content((label-w + 0.3, leg-y + 0.1), anchor: "west",
    text(size: 6.5pt, "enabler"))
  rect((label-w + 1.4, leg-y), (label-w + 1.6, leg-y + 0.2),
    fill: _ok-fill, stroke: _ok-stroke + 0.4pt)
  content((label-w + 1.7, leg-y + 0.1), anchor: "west",
    text(size: 6.5pt, "widget"))
}))

// ── Figure: Execution-harness request flow ────────────────────────
#let harness-flow() = _maybe-frame(canvas({
  import draw: *
  set-style(content: (padding: 2pt))

  // User block
  rect((-2.0, 1.2), (-0.5, 1.8),
    fill: rgb("#f1f5f9"), stroke: _muted + 0.5pt, radius: 1.5pt)
  content((-1.25, 1.5), anchor: "center",
    text(size: 7pt, weight: "bold", "User / Agent"))

  // API Gateway
  rect((0.4, 0.8), (2.4, 2.2),
    fill: _layer-fill, stroke: _layer-stroke + 0.6pt, radius: 2pt)
  content((1.4, 2.0), anchor: "center",
    text(size: 7.5pt, weight: "bold", "API Gateway"))
  content((1.4, 1.65), anchor: "center", text(size: 6pt, "auth"))
  content((1.4, 1.45), anchor: "center", text(size: 6pt, "rate-limit"))
  content((1.4, 1.25), anchor: "center", text(size: 6pt, "prompt filter"))
  content((1.4, 1.05), anchor: "center", text(size: 6pt, "PII redact"))

  // Inference Server (large box with internal stages)
  rect((3.0, 0.4), (8.4, 2.6),
    fill: _layer-fill, stroke: _layer-stroke + 0.6pt, radius: 2pt)
  content((5.7, 2.42), anchor: "center",
    text(size: 7.5pt, weight: "bold", "Inference Server"))

  // Internal pipeline boxes
  let stages = ("tokenize", "batch", "KV-cache", "decode")
  for (i, s) in stages.enumerate() {
    let x = 3.15 + i * 1.30
    rect((x, 0.95), (x + 1.15, 1.65),
      fill: rgb("#ffffff"), stroke: _layer-stroke + 0.4pt, radius: 1.5pt)
    content((x + 0.575, 1.3), anchor: "center",
      text(size: 6.5pt, s))
    if i < stages.len() - 1 {
      line((x + 1.16, 1.3), (x + 1.29, 1.3),
        stroke: _layer-stroke + 0.4pt, mark: (end: ">"))
    }
  }
  // model weights below pipeline
  content((5.7, 0.62), anchor: "center",
    text(size: 6pt, fill: _muted, style: "italic",
      "weights · safetensors / gguf loaded once"))

  // Sandbox (tool execution path, branches off)
  rect((6.4, 2.95), (8.4, 3.55),
    fill: _warn-fill, stroke: _warn-stroke + 0.5pt, radius: 1.5pt)
  content((7.4, 3.25), anchor: "center",
    text(size: 6.5pt, weight: "bold", fill: _warn-stroke, "Sandbox (tool calls)"))
  line((7.4, 2.62), (7.4, 2.95),
    stroke: _warn-stroke + 0.4pt, mark: (start: ">", end: ">"))

  // Arrows
  line((-0.45, 1.5), (0.35, 1.5),
    stroke: _layer-stroke + 0.5pt, mark: (end: ">"))
  line((2.45, 1.5), (2.95, 1.5),
    stroke: _layer-stroke + 0.5pt, mark: (end: ">"))
  // return arrow on top
  line((2.95, 1.85), (2.45, 1.85),
    stroke: _layer-stroke + 0.5pt, mark: (end: ">"))
  line((0.35, 1.85), (-0.45, 1.85),
    stroke: _layer-stroke + 0.5pt, mark: (end: ">"))

  // Adversaries
  content((-1.25, 1.0), anchor: "north",
    text(size: 6pt, fill: _adv-stroke, "ext-user injection"))
  content((7.4, 3.7), anchor: "south",
    text(size: 6pt, fill: _adv-stroke, "container escape"))
  content((5.7, 0.32), anchor: "north",
    text(size: 6pt, fill: _adv-stroke, "weight tamper / parser bug"))
}))

// ── Figure: Dependency supply-chain depth ─────────────────────────
// A schematic showing how a top-level ML project pulls 100+ transitive
// dependencies, with attack-surface depth.
#let dependency-tree() = _maybe-frame(canvas({
  import draw: *
  set-style(content: (padding: 2pt))

  let left-x = -2.2
  let right-x = 8.4
  let inner-w = right-x - left-x

  // Title
  let top-y = 4.2
  content((left-x, top-y + 0.4), anchor: "west",
    text(size: 8pt, weight: "bold",
      [The `PyPI` dependency surface @mahon2025pypitfall]))

  // Stat tiles (all numbers directly from Mahon et al. 2025).
  let tiles = (
    ("378K",  [`PyPI` packages\ analyzed]),
    ("129.6", [avg transitive\ deps per pkg]),
    ("23",    [max chain\ depth]),
    ("141K",  [pkgs exposed to\ known-vuln versions]),
  )
  let n = tiles.len()
  let tile-gap = 0.15
  let tile-w = (inner-w - (n - 1) * tile-gap) / n
  let tile-h = 1.1
  let tiles-top-y = top-y - 0.1
  for (i, (val, label)) in tiles.enumerate() {
    let x0 = left-x + i * (tile-w + tile-gap)
    rect((x0, tiles-top-y - tile-h), (x0 + tile-w, tiles-top-y),
      fill: _layer-fill, stroke: _layer-stroke + 0.5pt, radius: 2pt)
    content((x0 + tile-w / 2, tiles-top-y - 0.35), anchor: "center",
      text(size: 13pt, weight: "bold", val))
    content((x0 + tile-w / 2, tiles-top-y - 0.82), anchor: "center",
      text(size: 6.5pt, fill: _muted, label))
  }

  // Divider
  let div-y = tiles-top-y - tile-h - 0.35
  line((left-x, div-y), (right-x, div-y),
    stroke: _muted + 0.3pt)

  // Compromise callouts
  content((left-x, div-y - 0.35), anchor: "west",
    text(size: 7pt, weight: "bold", fill: _adv-stroke,
      [Real compromises that reached production via transitive pulls:]))

  let attacks = (
    ("2022", "torchtriton", [dependency confusion against `PyTorch`-nightly @pytorch2022torchtriton]),
    ("2024", "Ultralytics", [`CI/CD` injection · 60M+ `PyPI` downloads @reversing2024ultralytics]),
    ("2026", "litellm",     [direct `PyPI` upload bypassing the `GitHub` release pipeline @futuresearch2026litellm]),
  )
  let attack-y0 = div-y - 0.75
  let attack-step = 0.55
  for (i, (yr, name, desc)) in attacks.enumerate() {
    let y = attack-y0 - i * attack-step
    rect((left-x - 0.05, y - 0.18), (left-x + 0.5, y + 0.18),
      fill: _adv-fill, stroke: _adv-stroke + 0.4pt, radius: 1.5pt)
    content((left-x + 0.225, y), anchor: "center",
      text(size: 6.5pt, weight: "bold", fill: _adv-stroke, yr))
    content((left-x + 0.65, y), anchor: "west",
      text(size: 7pt, weight: "bold", raw(name)))
    content((left-x + 2.4, y), anchor: "west",
      text(size: 6.5pt, fill: _muted, desc))
  }
}))

// ── Figure 6: NVLink/NVSwitch trust boundary inside a node ────────
#let nvlink-topology() = _maybe-frame(canvas({
  import draw: *
  set-style(content: (padding: 2pt))

  // 8 GPUs in two rows of 4, NVSwitch in the middle
  let gw = 1.1
  let gh = 0.7
  let gap-x = 0.45
  let row-y = 2.35

  for i in range(4) {
    let x = i * (gw + gap-x)
    // top row
    rect((x, row-y), (x + gw, row-y + gh),
      fill: _layer-fill, stroke: _layer-stroke + 0.5pt, radius: 1.5pt)
    content((x + gw/2, row-y + gh/2), anchor: "center",
      text(size: 7pt, weight: "bold", "GPU " + str(i)))
    // bottom row
    rect((x, 0), (x + gw, gh),
      fill: _layer-fill, stroke: _layer-stroke + 0.5pt, radius: 1.5pt)
    content((x + gw/2, gh/2), anchor: "center",
      text(size: 7pt, weight: "bold", "GPU " + str(i + 4)))
  }

  // NVSwitch in the middle band
  let sw-x0 = 0.4
  let sw-x1 = 3 * (gw + gap-x) + gw - 0.4
  let sw-h = 0.75
  let sw-y = row-y/2 - 0.05
  rect((sw-x0, sw-y), (sw-x1, sw-y + sw-h),
    fill: _warn-fill, stroke: _warn-stroke + 0.6pt, radius: 2pt)
  content(((sw-x0 + sw-x1)/2, sw-y + sw-h/2), anchor: "center",
    text(size: 7.5pt, weight: "bold", fill: _warn-stroke,
      "NVSwitch · fabric manager\n(host-privileged)"))

  // NVLink lines from each GPU into the switch
  for i in range(4) {
    let x = i * (gw + gap-x) + gw/2
    line((x, row-y), (x, sw-y + sw-h),
      stroke: _layer-stroke + 0.4pt)
    line((x, gh), (x, sw-y),
      stroke: _layer-stroke + 0.4pt)
  }

  // Tenant boundary: dashed box around GPUs 0-3 and another around 4-7
  let tb-pad = 0.18
  rect((-tb-pad, row-y - tb-pad), (3 * (gw + gap-x) + gw + tb-pad, row-y + gh + tb-pad),
    stroke: (paint: _ok-stroke, dash: "dashed", thickness: 0.6pt))
  content((3 * (gw + gap-x) + gw + tb-pad + 0.1, row-y + gh/2),
    anchor: "west",
    text(size: 6.5pt, fill: _ok-stroke, weight: "bold", "tenant A"))

  rect((-tb-pad, -tb-pad), (3 * (gw + gap-x) + gw + tb-pad, gh + tb-pad),
    stroke: (paint: _adv-stroke, dash: "dashed", thickness: 0.6pt))
  content((3 * (gw + gap-x) + gw + tb-pad + 0.1, gh/2),
    anchor: "west",
    text(size: 6.5pt, fill: _adv-stroke, weight: "bold", "tenant B"))
}))

#let layer-adversary-matrix(layer-invites) = _maybe-frame(canvas({
  import draw: *
  set-style(content: (padding: 1.5pt))

  let cw = 1.2  // column width
  let rh = 0.55 // row height
  let ox = 2.6  // x-offset for first column
  let oy = 0    // y-offset for first row

  // Column headers (adversaries)
  for (i, aid) in _adv-order.enumerate() {
    content((ox + i * cw + cw/2, _layer-order.len() * rh + 0.15),
      anchor: "south",
      text(size: 6.5pt, fill: _adv-stroke, _adv-short.at(aid)))
  }

  // Row labels (layers) and cells
  for (ri, (lid, lname)) in _layer-order.enumerate() {
    let y = (_layer-order.len() - 1 - ri) * rh
    content((ox - 0.1, y + rh/2), anchor: "east",
      text(size: 7pt, weight: "bold", lname))
    let invites = layer-invites.at(lid, default: ())
    for (ci, aid) in _adv-order.enumerate() {
      let x = ox + ci * cw
      let hit = aid in invites
      rect((x, y), (x + cw, y + rh),
        fill: if hit { _adv-fill } else { rgb("#f8fafc") },
        stroke: if hit { _adv-stroke + 0.4pt } else { rgb("#e2e8f0") + 0.4pt })
      if hit {
        content((x + cw/2, y + rh/2), anchor: "center",
          text(size: 9pt, fill: _adv-stroke, weight: "bold", "●"))
      }
    }
  }
}))
