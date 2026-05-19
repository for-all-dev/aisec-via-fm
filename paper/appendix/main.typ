#import "../common/fns.typ": adversary-table, layer-invites
#import "../common/figures.typ": layer-adversary-matrix

= Appendix: Adversary taxonomy <sec:appendix-adversaries>

The _Invites_ tags on each stack layer (@sec:stack) and the _Blocks_ tags on each tractable problem (@sec:tractable-problems) draw from a fixed set of adversary archetypes. The same taxonomy populates the tooltips on the website. Each archetype is named for the position it occupies relative to the target system, not for a specific actor or organization.

#adversary-table()

#v(1em)

#figure(
  layer-adversary-matrix(layer-invites),
  caption: [Which adversary archetypes each stack layer invites. The same `// Invites:` headers drive the per-layer tags in @sec:stack; this matrix is just an at-a-glance view of the bipartite relation.],
) <fig:layer-adv-matrix>
