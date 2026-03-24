// Tag: oci-runtime-hardening
// Layers: orchestration-cloud, execution-harness

== OCI Runtime Hardening <sec:oci-hardening>

The standard container runtime, `runc`, implements the OCI specification atop Linux namespaces and cgroups. It was never designed to resist an adversary _inside_ the container, and the CVE record reflects this. When the workload in question is an AI agent with tool use (i.e. one that can write and execute arbitrary code), the gap between "process isolation" and "security boundary" becomes the whole game.

Recent benchmark work has started to quantify the gap. @marchand2026sandboxescape measures frontier LLM capabilities for container sandbox escape directly, treating the model as a red-team operator. The UK AISI sandboxing toolkit @ukgov2025aisandboxing and its Docker Sandbox Breakout CTF @ukgov2026sandboxbreakout provide standardized escape scenarios built on Inspect AI @inspectai2025. @kaufman2025basharena introduces BashArena, a control setting specifically for highly privileged agents. BoxArena @dougherty2026boxarena inverts the usual offensive framing: instead of asking "can this agent escape?", it fixes the attacker model and varies the OCI runtime, producing a _defensive_ leaderboard. Five attack surfaces (filesystem, socket, process, network, syscall) are tested across runtimes like runc, gVisor's `runsc`, `crun`, and Kata Containers.

The pattern across all of these is convergent: empirical red-teaming finds holes, patches get applied, and next quarter a new escape surfaces. A sufficiently capable agent should be assumed to find any flaw in its containment. This is where formal methods enters.

=== Solution/project Sketch <sec:oci-hardening-sketch>

What would a _formally verified OCI runtime_ look like? The lineage runs through the CLInc stack @bevier1989clinc (end-to-end verified from gate-level hardware through compiler to application) and seL4 @klein2009sel4 (functional correctness of a microkernel, machine-checked in Isabelle/HOL). A verified OCI runtime would prove that the namespace and capability isolation enforced by the runtime matches a formal policy -- that no sequence of syscalls from inside the container can violate the confinement invariant.

This is a large artifact, but it decomposes into tractable pieces: a formal model of the relevant Linux ABI surface (the ~80 syscalls a hardened container actually needs), a specification of the confinement policy (drop all capabilities, read-only rootfs, seccomp allowlist, no-new-privileges), and a proof that the runtime's state machine preserves the policy across all reachable states.

The AI control literature @greenblatt2024aicontrol @bhatt2025ctrlz adds another dimension: even with a verified runtime, you want a _monitor_ -- a second model or policy that reviews agent actions before they reach the kernel. The combination of a verified isolation boundary and a scalable monitor protocol is stronger than either alone, and the monitor's job gets easier when the boundary it sits behind has a proof.
