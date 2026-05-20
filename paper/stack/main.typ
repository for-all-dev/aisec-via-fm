#import "../common/figures.typ": stack-overview

= The ML Inference and Training Stack <sec:stack>

The five layers below run top to bottom in the order an adversary walks the stack. Each section that follows opens on the layer's status quo and current attack surface, then surfaces the FM-shaped widgets that would close part of it. Scope follows @sec:scope --- infrastructure only; the model itself is out of frame.

#figure(
  stack-overview(),
  caption: [The five layers of the ML inference and training stack, with the adversary archetypes (left) that each layer invites and the assets (right) that pass through them. Adversaries are tagged on each layer below using the same labels; see @sec:appendix-adversaries for full descriptions.],
) <fig:stack-overview>

#include "execution-harness.typ"
#include "software-framework.typ"
#include "orchestration-cloud.typ"
#include "firmware-lowlevel.typ"
#include "hardware-supply-chain.typ"
