#import "common/fns.typ": *

// ── Document settings ────────────────────────────────────────────
#set document(title: "Tractable Problems in AI Security via Formal Methods")
#set page(
  paper: "us-letter",
  margin: (x: 1in, y: 1in),
  footer: align(center,
    text(size: 7pt, fill: gray,
      [Draft — #datetime.today().display("[year]-[month]-[day]") · git:#git-commit]
    )
  ),
)
#set text(size: 11pt, font: "New Computer Modern")
#set par(justify: true)
#set heading(numbering: "1.1")

// ── Title block ──────────────────────────────────────────────────
#align(center, text(17pt, weight: "bold")[#paper_title])
#v(.5em)
#align(center, table(
  columns: authors.len(),
  align: center + horizon,
  stroke: none,
  inset: 6pt,
  ..authors.map(a => [
    *#a.name* \
    #if "organization" in a [#a.organization \ ]
    #raw(a.email)
  ]),
))
#v(1em)
#block(
  inset: 10pt,
  fill: rgb("#F8FAFC"),
  stroke: rgb("#CBD5E1"),
  radius: 4pt,
)[
  *Abstract.* #paper_abstract
]
#v(1.5em)

// ── Body ─────────────────────────────────────────────────────────
#include "executive/main.typ"
#include "stack/main.typ"
#include "problems/main.typ"

// ── Bibliography ─────────────────────────────────────────────────
#bibliography("refs.bib")
