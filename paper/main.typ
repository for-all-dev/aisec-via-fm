#import "@preview/charged-ieee:0.1.4": ieee
#import "common/authors.typ": authors
#import "common/fns.typ": *

#show: ieee.with(
  title: [Tractable Problems in AI Security via Formal Methods],
  abstract: [#lorem(80)],
  authors: authors,
  index-terms: ("AI Security", "Formal Methods", "ML Stack", "Program Synthesis"),
  bibliography: bibliography("refs.bib"),
)

#include "chapters/introduction/main.typ"
#include "chapters/stack/execution-harness.typ"
#include "chapters/stack/software-framework.typ"
#include "chapters/stack/orchestration-cloud.typ"
#include "chapters/stack/firmware-lowlevel.typ"
#include "chapters/stack/hardware-supply-chain.typ"
#include "chapters/tractable-problems/main.typ"
