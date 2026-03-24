# Orchestration & Cloud Layer: Security Incidents, Vulnerabilities, and FM Opportunities

Research compiled 2026-03-24. Covers 2023-2026 findings across four subsections.

---

## 1. Cluster Orchestration (Kubernetes, Slurm, Ray)

### Kubernetes

**IngressNightmare (CVE-2025-1974) -- March 2025**
- CVSS 9.8. Unauthenticated RCE via Ingress-NGINX admission webhook.
- Part of a family of 5 CVEs: CVE-2025-1098, CVE-2025-1974, CVE-2025-1097, CVE-2025-24514, CVE-2025-24513.
- Discovered by Wiz Research. ~43% of cloud environments vulnerable. 6,500+ clusters (including Fortune 500) had admission controllers exposed to the public internet.
- Anything on the Pod network can exploit it -- no credentials or admin access required. Leads to full cluster takeover.
- Fix: ingress-nginx v1.12.1 / v1.11.5.
- Sources:
  - https://www.wiz.io/blog/ingress-nginx-kubernetes-vulnerabilities
  - https://kubernetes.io/blog/2025/03/24/ingress-nginx-cve-2025-1974/

**CVE-2024-10220 -- 2024**
- Critical. Deprecated gitRepo volume mechanism allows arbitrary command execution on the host with root privileges.
- Source: https://www.armosec.io/blog/kubernetes-cloud-native-cves-2024/

**CVE-2024-7598 -- 2024**
- Namespace termination race condition allowing bypass of network policy restrictions.

**Azure Airflow RBAC Misconfiguration -- Late 2024**
- Misconfigured RBAC in Azure Airflow allowed kubectl download, full cluster takeover, deployment of privileged pods, breakout to host VM, access to Azure-managed internal resources (Geneva, storage accounts, event hubs).
- Source: https://thehackernews.com/2024/12/misconfigured-kubernetes-rbac-in-azure.html

**Red Hat State of K8s Security 2024**: 89% of organizations experienced at least one K8s security incident; 40% detected container/K8s configuration issues.

### Ray (Distributed ML Framework)

**ShadowRay / CVE-2023-48022 -- Ongoing since 2023, major campaigns 2024-2025**
- CVSS 9.8. Missing authentication on Ray Jobs API allows unauthenticated RCE.
- **Disputed vulnerability**: Anyscale (Ray maintainer) considers this "by design" -- Ray assumes trusted network. Never patched.
- **ShadowRay 1.0** (discovered March 2024 by Oligo Security): First known attack campaign exploiting AI workloads in the wild. Hundreds of clusters compromised for crypto mining.
- **ShadowRay 2.0** (discovered Nov 2025): Self-propagating botnet. Threat actor "IronErn440" orchestrates via DevOps-style infrastructure and AI-generated payloads. Over 200,000 exposed Ray servers globally. Capabilities: crypto mining (XMRig), DDoS, data exfiltration, autonomous worm-like spreading.
- Poster child for "disputed CVE" problem in security.
- Sources:
  - https://www.oligo.security/blog/shadowray-2-0-attackers-turn-ai-against-itself-in-global-campaign-that-hijacks-ai-into-self-propagating-botnet
  - https://thehackernews.com/2024/03/critical-unpatched-ray-ai-platform.html
  - https://www.anyscale.com/blog/update-on-ray-cves-cve-2023-6019-cve-2023-6020-cve-2023-6021-cve-2023-48022-cve-2023-48023

### Slurm (HPC Workload Manager)

**CVE-2025-43904 -- 2025**
- CVSS 4.2 (moderate). Privilege escalation: Coordinator can promote user to Administrator via accounting system bug.
- Affects Slurm before 24.11.5, 24.05.8, and 23.11.11.
- Source: https://github.com/advisories/GHSA-2778-hrgh-cpxw

**CVE-2024-48936 -- 2024**
- Incorrect authorization in stepmgr. Attacker can execute processes under other users' jobs (limited to jobs with --stepmgr or globally enabled stepmgr).
- Source: https://support.bull.com/ols/product/security/psirt/security-bulletins/vulnerability-in-stepmgr-subsystems-psirt-1698-tlp-clear-version-2-3-cve-2024-48936

### FM Opportunity: Formal verification of cluster orchestration policies
- SMT-based verification of Kubernetes RBAC and admission policies (LTU thesis, 2024) converts RBAC rules to first-order logic, checks with SMT solver, prevents misconfigs that yield privilege escalation and multi-tenant issues.
- Source: https://ltu.diva-portal.org/smash/get/diva2:1991066/FULLTEXT01.pdf
- OPA Gatekeeper and Kyverno are policy-as-code tools, but lack formal verification -- policies are brittle, minor syntactic oversights or wildcard privileges silently create escalation paths.

---

## 2. Network Fabric (InfiniBand, RoCE, SDN, GPU Interconnects)

### InfiniBand / RDMA

**ReDMArk (USENIX Security 2021)**
- Demonstrated that InfiniBand security mechanisms are insufficient against both in-network and end-host attackers.
- Attacks: packet injection via impersonation, unauthorized memory access, DoS.
- Root cause: InfiniBand designed as internal data center tech, so encryption was never implemented.
- Source: https://www.usenix.org/conference/usenixsecurity21/presentation/rothenberger

**NeVerMore (ACM CCS 2022)**
- Unprivileged user can inject packets into any RDMA connection, bypassing OS/kernel security.
- Enables unauthorized block access to NVMe-oF storage devices.
- Source: https://dl.acm.org/doi/10.1145/3548606.3560568

**Linux Kernel RDMA Fix (2024)**
- Patched ib_umad_write() to reject negative data_len values, preventing memory corruption and privilege escalation in RDMA-enabled HPC/cloud systems.
- Source: https://windowsnews.ai/article/linux-kernel-rdma-security-fix-ib_umad_write-now-rejects-negative-data_len-values.405652

### NVLink / GPU Interconnect Side-Channel Attacks

**NVBleed (March 2025)**
- Covert and side-channel attacks on NVIDIA multi-GPU NVLink interconnect.
- Two leakage sources: timing variations from contention, accessible performance counters disclosing communication patterns.
- Covert channel: >70 Kbps bandwidth with 4.78% error rate across two GPUs.
- Application fingerprinting: 97.8% accuracy. Character identification in 3D rendering: >91% accuracy.
- **Cross-VM attacks possible in cloud environments.**
- Source: https://arxiv.org/abs/2503.17847

**"Beyond the Bridge" (2024)**
- Contention-based covert and side-channel attacks on multi-GPU interconnects.
- Adversaries monitor data transfer rates on shared NVLink protocol to glean information about other users.
- Source: https://arxiv.org/html/2404.03877v1

**"Spy in the GPU-box" (ISCA 2023)**
- Earlier work on covert/side-channel attacks in multi-GPU systems.
- Source: https://dl.acm.org/doi/abs/10.1145/3579371.3589080

### SDN Vulnerabilities

**CISA Alert: Cisco SD-WAN Exploitation (Feb 2026)**
- CVE-2026-20127: Previously undisclosed authentication bypass in Cisco SD-WAN, actively exploited globally.
- Source: https://www.cisa.gov/news-events/alerts/2026/02/25/cisa-and-partners-release-guidance-ongoing-global-exploitation-cisco-sd-wan-systems

**NSA Guidance (Dec 2023)**
- NSA published guidance on managing risk from SDN controllers, highlighting centralized controller as primary attack surface.
- Source: https://media.defense.gov/2023/Dec/12/2003357491/-1/-1/0/CSI_MANAGING_RISK_FROM_SDN_CONTROLLERS.PDF

### FM Opportunity: Formal verification of RDMA protocols and GPU interconnect isolation
- InfiniBand was designed without encryption; formal spec of isolation properties could define what "secure RDMA" means.
- NVLink side-channels are architectural -- FM could verify isolation guarantees or prove their absence.
- "Veiled Pathways" (2024) disclosed covert channels in NVIDIA encoder/decoder engines to NVIDIA.

---

## 3. Distributed Systems / Message Passing

### NCCL (NVIDIA Collective Communications Library)
- No public CVEs found for NCCL specifically.
- NCCL implements AllReduce, AllGather, Reduce, Broadcast, ReduceScatter, Send/Receive.
- Designed for performance, not security. Assumes trusted environment (similar to Ray's design philosophy).
- **Gap**: No formal verification of collective communication correctness. Research community focuses on optimization, not verification.

### Distributed Training Poisoning / Byzantine Attacks

**Federated Learning Attack Surface**
- Model poisoning: malicious workers report fabricated local training outcomes to compromise the global model.
- Data poisoning: label reversal and backdoor attacks.
- Existing defenses treat malicious updates as outliers, but fail when data is non-IID or multiple attackers collude.

**NDSS 2025: "Do We Really Need to Design New Byzantine-robust Aggregation Rules?"**
- Key finding: No need for new aggregation rules. FoundationFL secures FL by generating synthetic updates and applying existing rules (Trimmed-mean, Median).
- Provides theoretical convergence guarantees under Byzantine settings.
- Authors: Fang, Nabavirazavi, Liu, Sun, Iyengar, Yang.
- Source: https://www.ndss-symposium.org/ndss-paper/do-we-really-need-to-design-new-byzantine-robust-aggregation-rules/

**BVDFed (2024)**
- First Byzantine-resilient + Verifiable aggregation for Differentially Private Federated Learning.
- Uses "Loss Score" for trustworthiness + DPLoss rule to eliminate faulty gradients.
- Source: https://journal.hep.com.cn/fcs/EN/10.1007/s11704-023-3142-5

**Byzantine-Robust Decentralized FL (CCS 2024, CVPR 2024)**
- Dual-domain clustering + trust bootstrapping for decentralized settings.
- Sources:
  - https://dl.acm.org/doi/10.1145/3658644.3670307
  - CVPR 2024 paper on dual-domain clustering

### FM Opportunity: Verified collective communications and Byzantine-robust aggregation
- No formal verification exists for NCCL or MPI collective operations in ML context.
- GC3 compiler (2022) offers a high-level DSL for custom communication algorithms -- potential target for formal verification.
- Byzantine-robust aggregation rules have theoretical convergence proofs but not mechanized/machine-checked proofs.
- FRIDA workshop (Formal Reasoning in Distributed Algorithms) is active venue for this work.

---

## 4. Identity and Access Management (IAM)

### Model Weight Exfiltration / AI Model Theft

**RAND Report: "Securing AI Model Weights" (May 2024)**
- Identifies 38 distinct attack vectors for model weight theft.
- Defines 5 security levels (SL1-SL5) with 167 recommended security measures.
- Timeline estimates: ~1 year to SL3, 2-3 years to SL4, 5+ years to SL5 (requires national security community support).
- Priority measures: centralize weights on access-controlled systems, reduce authorized personnel, harden APIs, third-party red-teaming, insider threat programs, Confidential Computing.
- **None of these are widely implemented.**
- Hidden Layer survey (2024): 97% of IT pros prioritize AI security, but only 20% plan/test specifically for model theft.
- Sources:
  - https://www.rand.org/pubs/research_reports/RRA2849-1.html
  - https://www.rand.org/pubs/research_briefs/RBA2849-1.html

**ModeLeak: Vertex AI Privilege Escalation (Nov 2024)**
- Palo Alto Unit42 discovered two vulnerabilities in Google Vertex AI:
  1. Custom job permissions allow privilege escalation to service agent permissions (far broader than needed).
  2. Poisoned model uploaded to public repo can exfiltrate ML models and fine-tuned LLM adapters once deployed.
- Attackers could replicate custom tuning, exposing sensitive info in fine-tuning patterns.
- Google has since fixed these issues.
- Source: https://unit42.paloaltonetworks.com/privilege-escalation-llm-model-exfil-vertex-ai/

**Shadow Economy of Model Weight Trading**
- Illicit market for AI IP, with stolen frontier model weights potentially worth hundreds of millions.
- Source: https://www.ainewsinternational.com/the-shadow-economy-of-model-weight-trading-navigating-the-illicit-market-for-ai-ip/

### IAM Misconfigurations in Cloud/ML

**Cloud Misconfigurations as #1 Breach Cause**
- 99% of cloud security failures attributed to misconfigurations (open storage buckets, excessive IAM permissions, vulnerable network configs).
- Average breach cost: $4.88M globally.
- Documented attack chain: compromised credentials reached cloud admin privileges in 8 minutes, traversing 19 IAM roles, then enumerated Amazon Bedrock AI models and disabled model invocation logging.
- Source: https://fidelissecurity.com/threatgeek/threat-detection-response/cloud-misconfigurations-causing-data-breaches/

**2025 IAM Failures**
- M&S supply chain breach, Co-op ransomware attack, Harrods insider data leak -- all involved weak IAM.
- Source: https://www.cybersecurityintelligence.com/blog/iam-failures-lessons-from-2025s-biggest-breaches-8462.html

### Kubernetes RBAC Issues

**Azure Airflow RBAC Misconfiguration (Dec 2024)**
- See Cluster Orchestration section above. Full cluster takeover via RBAC misconfig.

**Red Hat Report**: 89% of orgs had K8s security incidents; RBAC over-permission is top source of cluster compromise.

**Common RBAC Anti-Patterns**: Unbounded ClusterRoleBindings, wildcard ("*") verbs, reliance on default service accounts.

### FM Opportunity: Formal verification of IAM/RBAC policies

**SMT-Based RBAC Verification (LTU 2024)**
- Converts Kubernetes RBAC + admission policies to first-order logic, verifies with SMT solver.
- Closes three gaps: conflict detection, attribute expressiveness, proof of policy correctness.
- Prevents image-supply-chain, privilege-escalation, and multi-tenant issues without modifying K8s core.
- Source: https://ltu.diva-portal.org/smash/get/diva2:1991066/FULLTEXT01.pdf

**Current State of Policy-as-Code**
- OPA Gatekeeper (Rego language, CNCF graduate) and Kyverno (YAML-native, CNCF incubating) are standard tools.
- Neither provides formal verification -- policies rely on manual review and linters.
- Gap: No mechanized proof that a given RBAC configuration satisfies stated security invariants.

---

## Cross-Cutting Themes

1. **"Trusted environment" assumptions are deadly**: Both Ray (CVE-2023-48022) and NCCL assume internal trusted networks. When deployed in real cloud environments, these assumptions fail catastrophically.

2. **Container escape is the critical boundary**: NVIDIA Container Toolkit CVE-2024-0132 (CVSS 9.0, TOCTOU race condition) affected 35% of cloud GPU environments. Incomplete patch led to CVE-2025-23359. NVIDIAScape (CVE-2025-23266, CVSS 9.0) is another container escape via OCI hooks.

3. **Side-channel attacks on GPU interconnects are an emerging class**: NVBleed, "Beyond the Bridge", "Spy in the GPU-box" demonstrate cross-VM information leakage via NVLink contention. No formal isolation guarantees exist.

4. **Model weights are the crown jewels**: RAND's 38 attack vectors and 167 security measures define the problem space. Only 20% of organizations specifically test for model theft.

5. **FM is underutilized in this layer**: The LTU thesis on SMT-based RBAC verification is one of very few examples of formal methods applied to orchestration-layer security. Massive opportunity for verified policies, verified collective communications, and proven isolation properties.
