#import "../common/figures.typ": stack-overview

= The ML Inference and Training Stack <sec:stack>

#lorem(60)

TODO: notes about what's in/out of scope.

#figure(
  stack-overview(),
  caption: [The five layers of the ML inference and training stack, with the adversary archetypes (left) that each layer invites and the assets (right) that pass through them. Adversaries are tagged on each layer below using the same labels; see @sec:appendix-adversaries for full descriptions.],
) <fig:stack-overview>

#include "execution-harness.typ"
#include "software-framework.typ"
#include "orchestration-cloud.typ"
#include "firmware-lowlevel.typ"
#include "hardware-supply-chain.typ"
