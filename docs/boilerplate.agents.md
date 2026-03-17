# Boilerplate Structure — Agent Notes

## File Layout

```
paper/
  main.typ                          — central template; imports authors, fns, includes all chapters
  refs.bib                          — bibliography (BibTeX)
  common/
    authors.typ                     — #let authors = (...) for Quinn Dougherty & Max von Hippel
    fns.typ                         — shared helpers: paper-title constant, layer-tag() fn
  chapters/
    introduction/main.typ           — = Introduction (AI security, FM, ML stack overview)
    stack/
      execution-harness.typ         — = Execution Harness
      software-framework.typ        — = Software and ML Framework Layer
      orchestration-cloud.typ       — = Orchestration and Cloud Layer
      firmware-lowlevel.typ         — = Firmware and Low-Level Systems
      hardware-supply-chain.typ     — = Hardware and Physical Supply Chain
    tractable-problems/main.typ     — = Tractable Problems; #includes all problem files
  problems/
    adversarial-robustness-fm.typ   — == Adversarial Robustness of Formal Methods
    sel4-gpu-drivers.typ            — == seL4 Native GPU Drivers
    oci-runtime-hardening.typ       — == OCI Runtime Hardening
    ai-control-proof-carrying-code.typ — == AI Control via Proof-Carrying Code
    network-tap-fpga.typ            — == Network Tap FPGA Specification
```

## Tag → Layer Relation Design

Each `paper/problems/*.typ` file carries a comment header:
```typst
// Tag: <slug>
// Layers: <layer-slug>, ...
```

The `<slug>` is the filename stem and becomes the tag identifier on the website.
`Layers:` lists which ML stack layers the problem is relevant to (many-to-many).

The website ingest pipeline should parse these comment headers to build the tag↔layer
relation. `paper/common/fns.typ` exports `layer-tag(name)` for inline use in the PDF.

## Make Targets

- `make paper` — compile PDF via `typst compile`
- `make dev`   — start Next.js dev server with paper watch
- `make build` — production build of website

## Next Steps for Website Integration

- The Next.js ingest script should watch `paper/problems/*.typ` and `paper/chapters/**/*.typ`.
- Parse `// Tag:` and `// Layers:` headers from problem files.
- Render `.typ` content as MDX or HTML (typst-ts or a custom parser TBD).
- Auth/commenting deferred; Supabase retrofit planned for later.
