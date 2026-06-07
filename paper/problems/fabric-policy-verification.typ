// Tag: fabric-policy-verification
// Layers: orchestration-cloud
// Adversaries: co-tenant, network-mitm
// Category: widget
// Authors: quinn

#import "../common/fns.typ": related-layers, adversaries-blocked

== Fabric Policy Verification <sec:fabric-policy>

#related-layers("fabric-policy-verification")
#adversaries-blocked("fabric-policy-verification")

Every tenant-isolation claim on a GPU cluster fabric bottoms out in configuration state: `P_Key` partition tables and forwarding tables programmed by the `InfiniBand` subnet manager, `NVSwitch` routing tables programmed by NVIDIA's fabric manager, VLAN and ACL configuration on the `RoCE`/Ethernet side (@sec:network-fabric). None of these artifacts has a semantics. The operator's evidence that tenants A and B cannot exchange packets is that someone read the config and believes it; across a fabric of thousands of ports under continuous reconfiguration --- node failures, topology changes, jobs arriving and departing --- that belief is not auditable, and a single mis-programmed table entry silently violates the isolation policy without violating anything the fabric itself checks.

For OpenFlow-style networks this problem is solved in principle and increasingly in practice. NetKAT @anderson2014netkat gives forwarding policies a sound and complete equational theory in which reachability and slice isolation are equivalence checks, and KATch @moeller2024katch decides those checks symbolically on realistic topologies in under a second --- fast enough to re-verify on every configuration change rather than once at design time. What does not exist is the packet and forwarding model for the fabrics AI clusters actually run on. NetKAT's semantics speaks OpenFlow Ethernet: match on header fields, modify, forward. `InfiniBand` subnet-managed routing, partition-key enforcement at ports and channel adapters, and `NVSwitch` address-range routing are different enough that the existing tooling does not apply off the shelf --- but they are not different in kind. The bet this widget makes is that the KAT machinery transfers and the missing work is modeling, not new theory.

=== Solution/project Sketch <sec:fabric-policy-sketch>

The deliverable is a NetKAT-style semantics for RDMA fabric configuration, a decision procedure for tenant non-interference over it, and an audit shim that runs the check continuously against live fabric state.

First, the semantics. Model the `InfiniBand` subnet as a KAT policy: linear forwarding tables become the forwarding relation, `P_Key` membership tables become tests at ingress and egress ports, and the subnet manager's view of the topology becomes the network term. Tenant isolation is then the standard NetKAT non-interference query --- the slice restricted to tenant A's `P_Key` composed with the slice restricted to tenant B's is equivalent to `drop` --- decided by an equivalence check in the style of @moeller2024katch. The `NVSwitch` case is the same shape one level down: the fabric manager's routing tables and address-range restrictions are the policy, and the isolation question is whether any GPU in one tenant's partition can reach an address range belonging to another's.

Second, the audit shim. The verified artifact is worth little if it checks a config that drifted from the fabric hours ago. Extract live state --- `OpenSM` forwarding and partition tables, fabric manager routing state --- compile it into the model, and re-run the non-interference check on every reconfiguration event, with a signed log of check results as the audit trail. This is the policy-side complement of the verified network tap (@sec:network-tap-fpga): the shim proves the installed configuration enforces isolation, and the tap's monitor stream is the evidence the fabric behaved as that configuration prescribes. It also gives the scheduler co-tenancy model (@sec:scheduler-cotenancy) something to discharge against --- a placement policy's "no shared network segment" constraint becomes a claim checkable in the fabric model rather than an assumption about labels.

Two natural stopping points. A `P_Key`-level model checked against real `OpenSM` table dumps from a production cluster, with the non-interference query running in seconds, is shippable and immediately useful to any operator making isolation claims to customers or auditors. The research contribution is the dynamic case: modern fabrics use adaptive routing, which reroutes traffic around congestion at runtime, and whether the isolation proof survives the full reachable set of adaptive-routing states --- rather than the single static table the subnet manager last wrote --- is exactly the kind of question the equational theory exists to answer and nobody has posed to it.
