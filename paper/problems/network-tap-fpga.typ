// Tag: network-tap-fpga
// Layers: orchestration-cloud, hardware-supply-chain
// Adversaries: network-mitm, physical-adversary
// Category: widget
// Authors: quinn

#import "../common/fns.typ": related-layers, adversaries-blocked

== Network Tap FPGA Specification <sec:network-tap-fpga>

#related-layers("network-tap-fpga")
#adversaries-blocked("network-tap-fpga")

The control plane that decides what flows where on a GPU cluster fabric --- SDN controllers, fabric managers, tenant routing tables (@sec:network-fabric) --- is the same piece of infrastructure whose compromise is the threat. An operator's own logs about what crossed which link cannot be evidence in a threat model where the operator's logging stack is on the attacker's side of the trust boundary. Independent observation on the fiber itself is the difference between "the controller says traffic between tenants A and B was partitioned" and "no such packet appeared on the inter-pod link during the audit window."

@cankaya2026taps develop this as the verification primitive for AI-datacenter compliance under mutual distrust between operator and external verifier. Their cost figures are the encouraging part of the picture: a north-south tap at the datacenter edge captures all external traffic at well under 0.01% of facility upfront cost; an east-west storage-fabric tap with full hash-and-timestamp capture sits at 0.3-0.75%; compute-fabric sampling via optical circuit switches at 0.2-1.5%. FPGA capture at 400 Gbps and above already has precedent in financial-regulation hardware (Arista 7130, Deutsche Börse). @amodo2026taps adds the optical reality the FPGA spec has to live with: passive splitters add no latency but eat link budget --- a 1 dB loss can break a 53 Gbaud link --- while active OEO taps regenerate the signal at roughly 20 ns latency and tens of watts but introduce a new failure point on the live link. The same artifact serves an internal threat model (compromised SDN controller, dishonest fabric manager) and an external one (treaty verifier, regulatory audit, third-party red team); the LTL contract below is identical, and the threat-model split surfaces only in key custody and in who is allowed to read the monitor leg --- policy rather than mechanism (@sec:mechanism-not-policy).

=== Solution/project Sketch <sec:network-tap-fpga-sketch>

A formally verified FPGA bitstream for an active optical-electrical-optical tap at 400 Gbps with a path to 800 Gbps. Three deliverables: a hardware specification in `Cryptol` or `SystemVerilog` with proofs in `SymbiYosys` or `Kami` against the LTL contract below; a tamper-evident reference design with externally inspectable interfaces; and an out-of-band verification cluster that consumes the monitor stream and runs compliance checks asynchronously, so the wire-side hardware stays simple enough to verify while sophisticated analysis happens elsewhere @cankaya2026taps.

Let `live_in(p, t)` mean packet `p` was clocked into the tap on the live ingress at time `t`; `live_out(p, t)` that it was clocked out on the live egress; `mon(r, t)` that the monitor leg emitted a record `r` at time `t`; and `fail(t)` that the tap has self-reported a fault. Let `D` and `D'` be the forwarding and mirroring deadlines in clock cycles, and let `image(p)` be the deterministic projection of `p` into the monitor record format (header parse + timestamp + payload hash, per @cankaya2026taps).

```ltl
-- P1: forwarding completeness (every live-in packet leaves on live-out in time)
G ( live_in(p) -> F[<= D] live_out(p) )

-- P2: forwarding fidelity (nothing on live-out that wasn't on live-in)
G ( live_out(p) -> O live_in(p) )

-- P3: mirror completeness (every live-in packet produces a monitor record)
G ( live_in(p) -> F[<= D'] mon(image(p)) )

-- P4: mirror soundness (every monitor record traces to a past live-in packet)
G ( mon(r) -> O exists p. live_in(p) /\ image(p) = r )

-- P5: no back-channel (live-out does not depend on monitor-leg inputs)
G ( live_out(p) -> not depends-on(p, mon_input) )

-- P6: fail-to-wire (a tap fault still preserves the forwarding path)
G ( fail -> G ( live_in(p) -> F[<= D] live_out(p) ) )
```

P1 and P2 together discharge the transparency obligation against the live forwarding path: nothing dropped, nothing synthesized. P3 and P4 discharge the monitor-leg faithfulness obligation: no missing packets, no fabricated ones. P5 is a hyperproperty rather than a pure LTL formula --- a noninterference statement that the live-out signal does not depend on any input received via the monitor leg --- and is the property that defeats the verifier-collusion attack in @cankaya2026taps's threat model. P6 is the fail-open invariant from @amodo2026taps: a tap component failure must downgrade the device to a transparent pass-through, not a link-cut, because the live link is load-bearing for production traffic.

The projection `image(p)` is where the spec interacts with policy. For east-west compute-fabric taps, `image(p)` is a header parse plus a SHA-3 payload hash --- the verifier learns timing and routing without payload contents. For north-south edge taps, the operator may retain session keys for post-hoc decryption under audit. Both factor through the same LTL contract; only the definition of `image` changes, which is the spec-implementation separability principle from @sec:separable-specs.

Two natural stopping points. A verified single-port tap with a stub fail-detection path, proven against P1-P6 modulo a hand-modeled SerDes layer, is shippable as a reference design. The same tap proven against a co-developed model of a real 400G PCS/SerDes is the research contribution; this is the same hardware-model gap that blocks GPU driver verification (@sec:device-drivers). Multimode fiber is out of scope --- the link budget does not admit passive splitting at high baud rates @amodo2026taps --- and the industry trend toward single-mode-only AI fabrics is the precondition this widget ships against.
