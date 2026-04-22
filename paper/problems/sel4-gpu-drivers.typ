// Tag: sel4-gpu-drivers
// Layers: firmware-lowlevel, hardware-supply-chain
// Adversaries: co-tenant, rogue-insider
// Category: widget
// Authors: quinn

#import "../common/fns.typ": related-layers, adversaries-blocked

== seL4 Native GPU Drivers <sec:sel4-gpu>

#related-layers("sel4-gpu-drivers")
#adversaries-blocked("sel4-gpu-drivers")

Multi-tenant GPU workloads today run on hypervisors whose TCB is orders of magnitude too large to verify, and whose GPU-facing driver is proprietary kernel code running at ring 0 (@sec:device-drivers). Two verified microkernels are candidates for hosting an ML-grade GPU stack: `seL4` @klein2009sel4, whose functional-correctness proof is the most complete but which has no GPU driver support at all, and `NOVA` @bluerocksec2024nova, whose partial proof covers concurrency and weak memory and whose microhypervisor architecture is explicitly designed for the host/guest split a GPU-passthrough workload needs.

The research methodology for verifying a driver --- separation-logic proofs against an abstract hardware model --- is settled @stewart2025sel4summit @bluerocksec2024vmmverification @bluerocksec2024cpusemantics. The real blocker is that the abstract hardware model does not exist. No GPU vendor publishes a machine-checkable specification of their command processor, MMU, or DMA engine; Peter Sewell's REMS Group has the most accurate public modeling work but is scoped to the CPU ISA @sewell2024rems. The tractable problem is accordingly two-sided: produce a formal model of a GPU command-submission interface at a fidelity that supports proof, and prove a driver against it.

=== Solution/project Sketch <sec:sel4-gpu-sketch>

Start with the smallest useful surface: the command-submission path of a single open-source GPU stack (`NVK`/`Nouveau` on NVIDIA, or an `AMDGPU` subset). Specify the command-ring state machine in `Rocq` or `Lean` at a level of detail that admits noninterference claims across tenant contexts --- ring-buffer consistency, IOMMU mapping integrity, context-switch scrubbing. Prove a reference driver (runnable under either `seL4`'s `sDDF` or `NOVA`'s userspace driver model) against that spec, with the security property being _no sequence of guest-supplied command packets causes the driver to program an IOMMU mapping or issue a DMA outside the guest's declared memory region_. Two natural stopping points: a verified command-submission module with a stubbed-in hardware model, which is shippable on its own as a reference; and the same driver proved against a model co-developed with the vendor or with REMS, which is the research contribution.
