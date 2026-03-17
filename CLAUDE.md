# Tractable Problems in AI Security via Formal Methods

This is a position paper, and though there will be a `.pdf` form factor, I think the first class consumer will interact with it via a nextjs site. So we'll have to automatically ingest `.typ` files to the website.



We will do separate `./paper/<chapter>/main.typ` files with a central template transcluding them in `./paper/main.typ`. Additionally, a `./paper/common/fns.typ` for common functions, maybe constants. Additionally, `./paper/problems/<problem>.typ` will each be small subheading-as-single-typst-file, and each `<problem>` generates a "tag" for the tagging system on the website. Basically we need a relation of some kind (possibly many-to-many? idk) between the 5 layers of the ML stack and the tractable problems. 

When drafting the boilerplate/code parts, use lorem ipsum liberally. Do not hallucinate actual content. 

## Goals of the document
the minimalist/uncontroverial version of the one-stop-shop document that you can send to any formal methods expert if they're worried about AI safety (or in some cases just take requirements lists for widgets from the doc and pay the formal methods expert to do them). 

- Mike (Dodds)'s desiderata: "Make it a doc that everyone thinks is sane and reasonable", minimal vision as a contrast with the very scifi position papers like "Towards Guaranteed Safe AI"
- Quinn's desiderata: instruction manual for how to spend 5-25 postdoc-years as soon as you read it

## The structure of the paper, sequentially in the `.pdf` version, will be:

### Introduction
- Background on AI security, maybe some SL5 background. brief worldview/forecasting notes (AGI/ASI ready).
- Background on FM and how it is being accelerated by AI.
  - brief notes on the secure program synthesis movement. 
- Background on the ML inference and training stack
  - detail on each section: hardware and physical supply chain, firmware and lowlevel systems, orchestration and cloud layer, software and ML framework layer, execution harness (i.e. from https to the claudecode tui or chatbot webapp).
  - discuss what's in and out of scope.

### Each of the 5 layers in the training stack: the status quo and how attackable it is, plus the FM opportunities/potential widgets to improve the situation
1. execution harness (i.e. from https to the claudecode tui or chatbot webapp).
  - Inference Servers: vLLM, TGI (Text Generation Inference), or Triton.
  - Sandboxes: The environments where AI-generated code (e.g., a "Code Interpreter") is actually executed.
  - API Gateways: The public-facing edge that handles rate limiting, prompt filtering, and monitoring.
2. software and ML framework layer
  - Compilers: Lowering high-level code to machine code (e.g., TVM, MLIR, XLA). This is a critical point for "poisoning" the logic.
  - Frameworks: PyTorch, JAX, and TensorFlow, CUDA.
  - Dependency Supply Chain: The thousands of Python/C++ packages (npm, PyPI) that make up the "ML-Ops" environment.
3. orchestration and cloud layer
  - Cluster Orchestration: Kubernetes (K8s), Slurm, or Ray. This handles how data flows between 10,000+ GPUs.
  - Network Fabric: High-speed interconnects (InfiniBand, RoCE) and the software-defined networking (SDN) that manages traffic isolation.
  - Distributed system / message passing protocol correctness.
  - Identity & Access Management (IAM): The logic governing who (or what agent) can read model weights or modify data pipelines.
4. firmware and lowlevel systems
  - Microkernels & Hypervisors: The virtualization layer (KVM, Xen) that isolates different "tenants" or AI jobs on the same physical chip.
  - Device Drivers & Runtimes: Proprietary stacks like Nvidia CUDA, AMD ROCm, or Intel oneAPI.
  - Boot Integrity: Secure Boot and Remote Attestation protocols that verify the hardware is running "clean" code.
5. hardware and physical supply chain
  - Chip Architecture: The RTL (Register Transfer Level) design of GPUs (Nvidia), TPUs (Google), and NPUs (Apple/Qualcomm).
  - Physical Security: Hardware Root of Trust (RoT), Secure Enclaves (Intel SGX, ARM TrustZone), and side-channel resistance.

### Tractable Problems
These are the shovel-ready project specs that move the needle on the above.

There's a whole consideration here for Secure Program Synthesis as a broader field, i.e. sometimes the projects get easier if secure program synthesis is a thriving community/industry. so we have to find a way to discuss that. 

- Adversarial robustness of/for FM (attacks and defenses in the field of proving false in ITPs). 
- seL4 native GPU drivers
- OCI runtime hardening
- AI control via proof carrying code
- network tap FPGA spec

## Working with the repo

- I think a `Makefile` at monorepo root that does everything
- `cd website && pnpm run build` or `&& pnpm run dev` should freshly populate (and dev should watch for changes) in the `./paper` dir. 
- Write notes to yourself/other AI agents in `./docs/*.agents.md`. 

Honestly, maybe we need to add auth and commenting ourselves in nextjs! I just don't think gdocs is a good product honestly! Table this, we'll retrofit `supabase` later if we want.

