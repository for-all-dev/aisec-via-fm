= Tractable Problems <sec:tractable-problems>

#let enablers = [*Enablers* are problems whose resolution unbottlenecks a class of downstream work. Adversarial robustness of formal methods (@sec:adversarial-robustness) is the clearest example: if an ITP's soundness can be broken by a sufficiently clever agent, then every verified artifact produced by that ITP inherits the vulnerability. Governance of neuralese proof stacks is similar --- if proof oracles start emitting proofs in representations humans cannot audit, spec elicitation and validation become unsolved problems for everything else in this document. Solving an enabler does not itself produce a deployable artifact, but failing to solve it degrades the value of the widgets that depend on it.]

#let widgets = [*Widgets* are concrete, scoped deliverables. Each widget stands on its own as a security improvement to a specific layer of the stack. Widgets are where the postdoc-years get spent and where the artifacts ship. The enabler/widget distinction matters for prioritization: an enabler with many dependents should be addressed early, and a widget whose value is contingent on an unsolved enabler should be sequenced accordingly.]

The problems below split into two kinds.
#enablers
#widgets


#include "advro.typ"
#include "spec-elicitation.typ"
#include "sel4-gpu-drivers.typ"
#include "oci-runtime-hardening.typ"
#include "ai-control-proof-carrying-code.typ"
#include "edge-policy-verification.typ"
#include "scheduler-cotenancy.typ"
#include "network-tap-fpga.typ"
#include "weight-integrity.typ"
#include "sampler-verification.typ"
#include "verified-input-parsers.typ"
#include "context-window-integrity.typ"
#include "capability-accumulation.typ"
#include "audit-log-integrity.typ"
#include "neuralese-gov.typ"
