== Execution Harness

The execution harness is the outermost software layer of an ML deployment: the wrapper that actually calls the model and handles its inputs and outputs. A user's prompt enters here, gets tokenized and batched, passes through the model, and returns as a completion. Because every interaction transits this layer, it is simultaneously the easiest place to bolt on security controls and the place where a failure is most directly exploitable from the outside.

Three components make up a typical execution harness, each with its own attack surface.

=== Inference Servers

An inference server (vLLM, Hugging Face TGI, Nvidia Triton) manages GPU memory, batches incoming requests for throughput, and exposes the model behind an HTTP or gRPC endpoint. The server is responsible for continuous batching, KV-cache management, and (increasingly) speculative decoding --- all performance-sensitive paths written in a mix of Python and C++/CUDA.

The security-relevant surface here is large. The server deserializes model weights, often from formats like SafeTensors or GGUF, that have had their own history of arbitrary-code-execution bugs. It accepts user-controlled input (prompts, generation parameters, LoRA adapter names) that flows deep into the batching and memory-allocation logic. A malformed request that triggers an out-of-bounds KV-cache write, for instance, could corrupt another user's in-flight completion in a multi-tenant deployment. Formal methods work in this area would target the memory-safety properties of the batching and caching layers, and correctness of the deserialization paths.

TODO: incorporate this somewhere https://futuresearch.ai/blog/litellm-pypi-supply-chain-attack/

=== Sandboxes

When an AI system can execute code --- a "code interpreter" in a chatbot, a tool-use agent writing and running scripts --- it needs a sandbox. In practice this means a containerized environment (often an OCI container or a microVM like Firecracker) with a constrained syscall profile and filesystem. The sandbox must prevent the AI-generated code from escaping to the host, exfiltrating data from other tenants, or persisting state across invocations in unintended ways.

The gap between "container" and "sandbox" is where real attacks live. Default container configurations are not security boundaries; they share a kernel with the host. A sandbox that allows `ptrace`, or that mounts the Docker socket, or that runs with `CAP_SYS_ADMIN`, is a sandbox in name only. The OCI runtime hardening problem (§~Tractable Problems) addresses this directly: writing machine-checked specifications for what a sandbox policy must guarantee and verifying that a given runtime configuration meets them.

=== API Gateways

The API gateway sits at the public edge. It handles authentication, rate limiting, content filtering, prompt injection detection, and usage metering. In many deployments this is a conventional reverse proxy (Envoy, Kong) with AI-specific middleware bolted on: a classifier that scans prompts for injection attempts, a filter that redacts PII from completions, a logger that records interactions for abuse review.

The security challenge is that these filters are making semantic decisions about adversarial input using heuristics or secondary ML classifiers --- an inherently brittle arrangement. A prompt injection that evades the filter is not a bug in the filter's code but a failure of its classification boundary. Formal methods have limited traction on the classification problem itself, but they can verify the _plumbing_: that the gateway's policy engine correctly composes its rules, that a request flagged by the filter cannot reach the model through an alternate code path, and that rate-limiting state cannot be poisoned by concurrent requests. The value here is ensuring that when a policy says "block this," the infrastructure actually does.
