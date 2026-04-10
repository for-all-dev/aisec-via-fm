// Tag: weight-integrity
// Layers: execution-harness, software-framework, firmware-lowlevel
// Category: widget
// Authors: quinn, maxvh

#import "../common/fns.typ": related-layers

== Weight Integrity and Kernel Supply Chain <sec:weight-integrity>

#related-layers("weight-integrity")

Model weights are the single highest-value static artifact in an ML deployment. A frontier model's checkpoint runs tens to hundreds of gigabytes, sharded across a distributed filesystem, and any bit-flip or deliberate modification in those shards changes the model's behavior in ways that are hard to detect at inference time. The threat model is straightforward: an adversary with write access to the storage layer --- compromised NFS node, supply-chain attack on a model registry like `Hugging Face`, or a privilege escalation on the serving host --- rewrites a weight shard. Existing defenses amount to hash-checking at load time. But the loader itself is a large, unverified C++/Python codebase, and the check is only as trustworthy as the code that performs it. A compromised loader can skip the check, and a hash collision (unlikely but not formally excluded) defeats it silently.

A second, orthogonal problem lives one layer deeper. The compute kernels that execute the forward pass --- matrix multiplications, attention, activation functions --- are supplied by hardware vendors as precompiled binaries. Nvidia's `cuBLAS` and `cuDNN` are closed source. AMD's `MIOpen` is partially open. In both cases, the optimized kernel that actually runs on the GPU is not the code anyone audited. A compromised kernel could introduce targeted numerical perturbations (a backdoor that activates on specific input patterns), exfiltrate data through covert timing channels, or silently degrade accuracy. You cannot inspect what you cannot read, but you _can_ check what it does against what it should do.

These two attack surfaces --- weight tampering and kernel compromise --- compose badly. If both the weights and the kernel are untrusted, the search space for an auditor explodes. Pinning one of them down with a formal guarantee makes the other tractable.

=== Solution/project Sketch <sec:weight-integrity-sketch>

The weight-loading pipeline should be verified end-to-end: from the filesystem `read()` call, through hash computation and comparison, to the final `cudaMemcpy` (or equivalent) that places weights in device memory. The postcondition is that the bytes in GPU memory are identical to the bytes committed by a known-good hash. This is a refinement proof --- show that the runtime representation is a faithful image of the storage representation, and that no intermediate step can silently substitute content. The verified loader then extends the remote attestation chain: the attestation report already covers firmware and boot integrity, so adding a weight-hash measurement means the serving infrastructure can refuse to run inference unless the full chain checks out. Model-checking the serving state machine (load, attest, serve) confirms that no path reaches the first forward pass without a valid attestation.

For the kernel supply chain, the tool is translation validation @pnueli1998translationvalidation. Each kernel gets a behavioral contract: "given input matrices $X$ and $W$, the output is $X W$ up to floating-point error $epsilon$." A validator checks the compiled binary against this contract without needing source code --- it works on the artifact, which is exactly what you want when the vendor won't ship source. As a stepping stone, differential testing against a formally verified reference implementation (a simple, correct matmul in, say, `Fiat Cryptography`'s @erbsen2019fiatcrypto style) catches gross violations cheaply. Translation validation catches subtle ones with a proof.
