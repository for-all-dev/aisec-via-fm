// Tag: device-drivers
// Layers: firmware-lowlevel, hardware-supply-chain
// Adversaries: co-tenant, rogue-insider
// Category: widget
// Authors: quinn, malecha

#import "../common/fns.typ": related-layers, adversaries-blocked

== Device Drivers for Verified Kernels <sec:device-drivers-verified-kernels>

#related-layers("device-drivers")
#adversaries-blocked("device-drivers")

Multi-tenant GPU workloads today run on hypervisors whose TCB is orders of magnitude too large to verify, and whose device-facing drivers are proprietary kernel code running at ring 0 (@sec:device-drivers). Every verified-core project --- the `seL4` @klein2009sel4 and `NOVA` @bluerocksec2024nova microkernels, and the tailored hypervisors `seKVM` @li2021sekvm and AWS's Nitro Isolation Engine @saidi2026nitroisolation --- deliberately pushes device drivers _out_ of the trusted core to keep the verified code small. The driver then runs deprivileged, in user mode, which is the right architecture but relocates the problem rather than removing it: tenant isolation now rests on the correctness of the user-mode driver and of the code that configures the kernel's protection policy.

That second dependency is the live trade-off. `seKVM` and Nitro bake their isolation policy _into_ the verified core --- pages cannot be shared across domains, and the proof says so --- which is a strong guarantee but a rigid one, awkward when domains legitimately need shared memory. `seL4` and `NOVA` instead expose rich capability-based APIs that let user mode allocate resources freely; the cost is that isolation holds only if the configuring code is correct. `seL4`'s `CAmkES` framework @kuz2007camkes verifies such configurations but only static ones; `NOVA`'s intended dynamic usage needs the isolation properties re-established by user-mode verification. Both ecosystems are pushing on exactly this: Kry10 @kry10 aims to raise `seL4`'s guarantees up the stack, and BlueRock has composed hypervisor- and user-mode proofs into whole-system guarantees @bluerock2025completesystems @bluerocksec2024vswitch.

The research methodology for verifying a single driver --- separation-logic proofs against an abstract hardware model, demonstrated for a `ZynqMP` DMA engine in concurrent separation logic @stewart2025sel4summit @bluerocksec2024vmmverification @bluerocksec2024cpusemantics --- is settled. The real blocker is that the abstract hardware model does not exist for the devices that matter. No GPU vendor publishes a machine-checkable specification of its command processor, MMU, or DMA engine; Peter Sewell's REMS Group has the most accurate public modeling work but is scoped to the CPU ISA @sewell2024rems. So the tractable problem is two-sided: produce a formal model of a device interface at a fidelity that supports proof, and prove a driver against it. The longer prize behind it is a verifiable _feature set_ --- enough of a hypervisor (dynamic provisioning, VM migration) and its user-mode drivers to run real workloads, kept small enough to stay in reach of current proof technology. Neither `seL4` nor `NOVA` can run a virtual machine in isolation today; identifying that minimal feature set is the precondition for everything above it.

=== Solution/project Sketch <sec:device-drivers-verified-kernels-sketch>

Start with the smallest useful surface: the command-submission path of a single open-source GPU stack (`NVK`/`Nouveau` on NVIDIA, or an `AMDGPU` subset). Specify the command-ring state machine in `Rocq` or `Lean` at a level of detail that admits noninterference claims across tenant contexts --- ring-buffer consistency, IOMMU mapping integrity, context-switch scrubbing. Prove a reference driver (runnable under either `seL4`'s `sDDF` or `NOVA`'s userspace driver model) against that spec, with the security property being _no sequence of guest-supplied command packets causes the driver to program an IOMMU mapping or issue a DMA outside the guest's declared memory region_. Two natural stopping points: a verified command-submission module with a stubbed-in hardware model, which is shippable on its own as a reference; and the same driver proved against a model co-developed with the vendor or with REMS, which is the research contribution.
