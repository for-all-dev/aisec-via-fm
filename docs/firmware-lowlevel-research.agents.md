# Firmware and Low-Level Systems Layer: Research Notes

Compiled 2026-03-24 for the position paper. All findings are from 2023-2026.

---

## 1. Microkernels and Hypervisors

### KVM Security

**Google kvmCTF Program (launched June 2024)**
- Google announced kvmCTF in October 2023, officially launched June 27, 2024.
- Offers up to $250,000 for full VM escape zero-day exploits targeting KVM.
- Hosted on Google's Bare Metal Solution (BMS) environment.
- Focuses exclusively on zero-day vulnerabilities (no known CVEs).
- Vulnerability details shared with open-source community only after upstream patches land.
- Sources:
  - https://www.bleepingcomputer.com/news/security/google-now-pays-250-000-for-kvm-zero-day-vulnerabilities/
  - https://securityboulevard.com/2024/08/kvmctf-googles-250k-bounty-for-kvm-zero-day-vulnerabilities/

**QEMU/KVM PCI SR-IOV Vulnerabilities**
- Multiple vulnerabilities in QEMU's PCI SR-IOV implementation (through version 10.0.3).
- Issues include VF Enable bit handling, migration state inconsistency, and buffer overflow when guests write NumVFs > TotalVFs.
- GPU passthrough inherently risky due to Direct Memory Access (DMA): devices can access arbitrary host physical memory addresses unless IOMMU is properly configured.
- Source: https://www.cvedetails.com/vulnerability-list/vendor_id-7506/Qemu.html

### Confidential Computing with GPUs

**NVIDIA H100 Confidential Computing (first confidential GPU)**
- H100 is the first GPU with confidential computing support, ready since CUDA 12.2 Update 1.
- On-die Root of Trust (RoT) with measured/attested boot.
- Each H100 has a unique ECC keypair burned into fuses at manufacturing.
- GPU signs firmware measurements + Diffie-Hellman parameters for remote attestation.
- NVIDIA Remote Attestation Service (NRAS) is primary verification method; air-gapped options available.
- Multi-GPU attestation (PPCIE) supports NVSwitch interconnect configurations.
- Open-sourced `go-nvtrust` library for GPU and NVSwitch attestation.
- Sources:
  - https://developer.nvidia.com/blog/confidential-computing-on-h100-gpus-for-secure-and-trustworthy-ai/
  - https://docs.nvidia.com/nvtrust/index.html
  - https://forums.developer.nvidia.com/t/open-sourcing-go-nvtrust-a-go-library-for-nvidia-gpu-and-nvswitch-confidential-computing-attestation/347785

**NVIDIA GPU-CC Security Analysis (IBM Research + Ohio State, July 2025)**
- Paper: "NVIDIA GPU Confidential Computing Demystified" (arXiv:2507.02770).
- KEY FINDING: GPU-CC does NOT encrypt GPU memory at runtime (unlike CPU TEEs). Relies solely on access-control firewalls.
- Researchers reverse-engineered GPU-CC bootstrap and data protection mechanisms.
- Identified potential information leaks through untrusted interfaces.
- Called for greater transparency from hardware vendors.
- All findings responsibly disclosed to NVIDIA PSIRT.
- Sources:
  - https://arxiv.org/abs/2507.02770
  - https://www.sdxcentral.com/news/nvidia-confidential-gpu-probe-uncovers-key-security-gaps/

**Intel Trust Authority + NVIDIA GPU Attestation (September 2024)**
- Joint Intel/NVIDIA attestation: attest both CPU TEE (TDX) and GPU TEE in one composite workflow.
- Intel Trust Authority SaaS verifies TDX quote, forwards GPU evidence to NRAS.
- Source: https://docs.trustauthority.intel.com/main/articles/articles/ita/concept-gpu-attestation.html

**AMD SEV-SNP vs Intel TDX vs NVIDIA GPU TEE**
- GPU-CC cannot operate independently; requires CPU-CC (Intel TDX or AMD SEV-SNP).
- As of October 2024, Confidential VM with NVIDIA H100 GPU in preview on Google Cloud A3 machines.
- Intel TDX has smallest TCB and strongest encryption (AES-256).
- Sources:
  - https://phala.com/learn/AMD-SEV-vs-Intel-TDX-vs-NVIDIA-GPU-TEE
  - https://cloud.google.com/blog/products/identity-security/expanding-confidential-computing-for-ai-workloads-next24

### seL4 and Verified Microkernels

**seL4 Device Driver Framework (sDDF)**
- GPU support currently via Linux driver VMs (not natively verified GPU drivers).
- sDDF v0.6.0 released March 2025; v0.5.0 released August 2024.
- Ethernet driver: <600 LOC vs ~5,000 LOC for equivalent Linux driver, with better throughput.
- Source: https://github.com/au-ts/sDDF

**First Verified Device Driver for Non-Trivial Device (2024-2025)**
- Formally verified Ethernet driver for seL4-based LionsOS using Pancake language.
- Pancake: imperative systems programming language with a verified compiler.
- Integrated into Viper SMT verification infrastructure via automatic transpiler.
- Verification of i.MX 1 Gb/s Ethernet driver (NXP i.MX 8M processors).
- Paper: "Verifying Device Drivers with Pancake" (arXiv:2501.08249, January 2025).
- Proofs mechanized in Isabelle/HOL-compatible infrastructure.
- Sources:
  - https://arxiv.org/html/2501.08249
  - https://sel4.systems/Summit/2024/abstracts2024.html

**seL4 Ongoing Research Program**
- Extending to multikernel operation.
- Hardening against side-channel attacks.
- Driver verification framework.
- Building seL4-based operating systems.
- Source: https://trustworthy.systems/projects/seL4/

---

## 2. Device Drivers and Runtimes

### NVIDIA GPU Driver Vulnerabilities

**NVIDIAScape / CVE-2025-23266 (CVSS 9.0 Critical, disclosed ~July 2025)**
- Critical container escape in NVIDIA Container Toolkit.
- OCI hook misconfiguration: `createContainer` hook trusts unfiltered environment variables.
- Setting `LD_PRELOAD` in a Dockerfile forces hook to load malicious library, breaking container boundary.
- Three-line Dockerfile weaponizes it -> root access on host.
- ~37% of cloud environments susceptible.
- Affects NVIDIA Container Toolkit <= 1.17.7 and GPU Operator <= 25.3.0.
- Fixed in Toolkit v1.17.8 and GPU Operator 25.3.1.
- Sources:
  - https://www.wiz.io/blog/nvidia-ai-vulnerability-cve-2025-23266-nvidiascape
  - https://zeropath.com/blog/nvidiascape-cve-2025-23266-nvidia-container-toolkit-escape

**CVE-2025-23280 (CVSS 7.0 High)**
- Use-after-free in NVIDIA Display Driver for Linux.
- Driver accesses freed memory; attacker with local access exploits race conditions.
- Affects workstations, servers, desktops.
- Source: https://zeropath.com/blog/cve-2025-23280-nvidia-linux-use-after-free-summary

**CVE-2024-0126 (Privilege Escalation)**
- NVIDIA GPU Display Driver for Windows and Linux.
- Enables attackers to gain elevated permissions.
- Source: https://www.sentinelone.com/vulnerability-database/cve-2024-0126/

**CVE-2024-0107 (Out-of-Bounds Read)**
- NVIDIA GPU Display Driver for Windows.
- Unprivileged user can trigger out-of-bounds read in user mode layer.
- Source: https://www.sentinelone.com/vulnerability-database/cve-2024-0107/

**CVE-2024-0117 through CVE-2024-0121 (Multiple)**
- Out-of-bounds memory access in GPU display driver and vGPU software.
- Potential for code execution, DoS, privilege escalation, information disclosure.
- Source: https://nvidia.custhelp.com/app/answers/detail/a_id/5586/

**October 2025 Security Bulletin**
- CVE-2025-23282 (race condition, Linux), CVE-2025-23309 (uncontrolled DLL loading, Windows), and others.
- Source: https://nvidia.custhelp.com/app/answers/detail/a_id/5703/

### NVIDIA vGPU Vulnerabilities

**CVE-2024-53881 (published January 2025)**
- vGPU host driver vulnerability: guest can cause interrupt storm on host -> DoS.
- Source: https://www.cvedetails.com/cve/CVE-2024-53881/

### NVIDIA CUDA Toolkit Vulnerabilities (February 2025)

- Nine vulnerabilities in `cuobjdump` and `nvdisasm` utilities.
- Stack-based buffer overflow in cuobjdump via malicious ELF file -> potential arbitrary code execution.
- Heap-based buffer overflow in nvdisasm -> potential arbitrary code execution.
- Use-after-free in nvdisasm via malformed ELF -> limited DoS/info disclosure.
- Source: https://unit42.paloaltonetworks.com/nvidia-cuda-toolkit-vulnerabilities/

**September 2025 CUDA Toolkit Bulletin**
- Additional vulnerabilities patched.
- Source: https://nvidia.custhelp.com/app/answers/detail/a_id/5661/

### AMD Vulnerabilities

**CVE-2024-56161 (CVSS 7.2 High) -- AMD SEV-SNP Microcode Injection**
- Improper signature verification in AMD CPU ROM microcode patch loader.
- CPU uses insecure hash function for microcode update signature validation.
- Attacker with local admin (ring 0, outside VM) can load arbitrary malicious microcode.
- Demonstrated on Zen 1 through Zen 4 CPUs.
- Compromises SEV-SNP confidential computing and Dynamic Root of Trust Measurement.
- Discovered by Google researchers: Josh Eads, Kristoffer Janke, Eduardo Vela, Tavis Ormandy, Matteo Rizzo.
- Reported: September 25, 2024. Fixed: December 17, 2024. Disclosed: February 3, 2025.
- Sources:
  - https://github.com/google/security-research/security/advisories/GHSA-4xq7-4mgh-gp6w
  - https://thehackernews.com/2025/02/amd-sev-snp-vulnerability-allows.html
  - https://nvd.nist.gov/vuln/detail/CVE-2024-56161

**CVE-2024-36347 (CVSS 6.4 Medium) -- CPU ROM Microcode Signature Verification**
- Improper signature verification in CPU ROM microcode patch loader.
- Local admin can bypass security and load arbitrary microcode.
- Affects AMD EPYC, Ryzen 3000/5000/9000, desktop/mobile/server/embedded.
- Firmware updates: EPYC December 2024, Ryzen desktop January-March 2025.
- Source: https://www.amd.com/en/resources/product-security.html

**AMD Graphics Vulnerabilities (August 2025)**
- AMD-SB-6018 security bulletin.
- Source: https://www.amd.com/en/resources/product-security/bulletin/amd-sb-6018.html

### Formal Verification of Device Drivers

**GPUVerify (Oxford/Imperial)**
- Formal verification of GPU kernels (OpenCL, CUDA).
- Checks data races and barrier divergence.
- Sources:
  - https://www.cs.ox.ac.uk/seminars/984.html
  - https://dl.acm.org/doi/10.1145/2743017

**Formal GPU Model (Princeton)**
- First instruction-level formal model for GPUs at the PTX level.
- Supports non-synchronization instructions and all synchronization primitives.
- Source: https://www.cs.princeton.edu/~aartig/papers/iccad18-gpu.pdf

**GPU Side-Channel Attack Classification (2024)**
- Systematic classification of GPU side-channel vectors: power analysis, timing, electromagnetic, combined.
- GPU parallel architecture and shared resources introduce significant vulnerabilities.
- Source: https://link.springer.com/article/10.1007/s42979-024-03514-9

---

## 3. Boot Integrity

### UEFI Secure Boot Bypass Vulnerabilities

**CVE-2024-7344 (Secure Boot Bypass, January 2025)**
- Discovered by ESET researchers.
- Affects majority of UEFI-based systems.
- Vulnerable UEFI application uses custom PE loader instead of trusted `LoadImage`/`StartImage`.
- Allows execution of untrusted code during boot -> malicious UEFI bootkits (Bootkitty, BlackLotus).
- Application was signed by Microsoft's "Microsoft Corporation UEFI CA 2011" certificate.
- Revoked by Microsoft in January 14, 2025 Patch Tuesday.
- Sources:
  - https://www.welivesecurity.com/en/eset-research/under-cloak-uefi-secure-boot-introducing-cve-2024-7344/
  - https://www.helpnetsecurity.com/2025/01/16/uefi-secure-boot-bypass-vulnerability-cve-2024-7344/

**CVE-2025-3052 / BRLY-2025-001 (Memory Corruption)**
- Module signed with Microsoft's third-party UEFI certificate.
- Improper handling of NVRAM variable `IhisiParamBuffer`; used as memory pointer without validation.
- Attacker can overwrite `gSecurity2` flag to disable Secure Boot.
- Execute unsigned code during DXE phase.
- Affects any device trusting "Microsoft Corporation UEFI CA 2011" certificate (vast majority of systems).
- Source: https://www.binarly.io/blog/another-crack-in-the-chain-of-trust

**CVE-2025-4275 "Hydrophobia" (Insyde H2O)**
- Allows attackers to bypass Secure Boot in Insyde H2O firmware.
- Source: https://eclypsium.com/blog/hydrophobia-secure-boot-bypass-vulnerabilities/

**UEFI DMA Attack Vulnerabilities (CVE-2025-11901, -14302, -14303, -14304)**
- Affects motherboards from ASUS, Gigabyte, MSI, ASRock.
- IOMMU not correctly initialized during early boot.
- Firmware falsely signals Pre-Boot DMA Protection is active.
- Requires physical access (malicious PCIe device).
- Source: https://thehackernews.com/2025/12/new-uefi-flaw-enables-early-boot-dma.html

### UEFI Bootkits

**LogoFAIL (disclosed December 2023, exploited 2024-2025)**
- Multiple image-parsing vulnerabilities in UEFI code across vendors.
- Can hijack boot execution flow and deliver bootkits.
- Binarly considers it more dangerous than BlackLotus.
- LogoFAIL exploited to deploy Bootkitty, the first UEFI bootkit for Linux.
- Remains unpatched on hundreds of devices in the wild.
- Sources:
  - https://www.binarly.io/blog/logofail-exploited-to-deploy-bootkitty-the-first-uefi-bootkit-for-linux
  - https://www.bleepingcomputer.com/news/security/logofail-attack-can-install-uefi-bootkits-through-bootup-logos/

**BlackLotus (2023, ongoing relevance)**
- First publicly known UEFI bootkit bypassing Secure Boot on fully updated Windows 11.
- Sold on hacking forums for $5,000.
- Exploits CVE-2022-21894.
- Source: https://www.welivesecurity.com/2023/03/01/blacklotus-uefi-bootkit-myth-confirmed/

### Remote Attestation and TPM

**NVIDIA GPU Remote Attestation Architecture (September 2024)**
- Joint Intel/NVIDIA architecture diagram published.
- Composite attestation: Intel TDX + NVIDIA GPU TEE in single workflow.
- See confidential computing section above for details.

**RFC 9683 (December 2024)**
- IETF standard for remote attestation of network device integrity using TPMs.
- Describes workflow for remote verification of firmware and software.
- Source: https://datatracker.ietf.org/doc/rfc9683/

**EK-Based Key Attestation with TPM Firmware Version (TCG, October 2025)**
- Trusted Computing Group specification.
- Guidance for TPM key-attestation verifiers to receive trustworthy signal of TPM firmware version.
- Source: https://trustedcomputinggroup.org/wp-content/uploads/EK-Based-Key-Attestation-with-TPM-Firmware-Version-Version-1_Pub.pdf

**TPM + TEE Combined Attestation (CNCF, October 2025)**
- TPM-based and TEE-native attestation can coexist.
- Joint attestation mechanisms collect, verify, and combine both evidence types.
- Source: https://www.cncf.io/blog/2025/10/08/a-tpm-based-combined-remote-attestation-method-for-confidential-computing/

### Formal Verification of Boot

**PA-Boot: Formally Verified Secure Boot Protocol**
- First formally verified processor-authentication protocol for secure boot in multiprocessor systems.
- Detects multiple adversarial behaviors under hardware supply-chain attacks.
- Proofs mechanized in Isabelle/HOL: 306 lemmas/theorems, ~7,100 LOC.
- Source: https://arxiv.org/html/2209.07936v2

**Formal Verification of Secure Boot Process (IEEE, 2024)**
- UPPAAL model checking for boot loader code analysis.
- Can identify vulnerabilities using formal properties.
- Source: https://ieeexplore.ieee.org/document/10546576/

**Post-Quantum Secure Boot (2025 onward)**
- CRYSTALS-Dilithium and Falcon entering pilot use in embedded secure boot chains.
- Hybrid signing (ECDSA + post-quantum) expected to dominate 2025-2030 transition.

### NSA/CISA Guidance

**NSA/CISA UEFI Secure Boot Guidance (December 2025)**
- Joint guidance document for managing UEFI Secure Boot.
- Source: https://media.defense.gov/2025/Dec/11/2003841096/-1/-1/0/CSI_UEFI_SECURE_BOOT.PDF

---

## Key Themes for the Paper

1. **GPU confidential computing is immature**: H100 is first-gen, memory not encrypted at runtime, relies on firewalls. The attack surface is large and under-analyzed.

2. **Microcode is a critical trust boundary**: Both AMD CVEs (CVE-2024-56161, CVE-2024-36347) show that microcode signature verification is fragile. Google proved they could craft arbitrary malicious microcode for Zen 1-4.

3. **Container escape is the most immediate ML infra threat**: NVIDIAScape (CVE-2025-23266) is a 3-line container escape affecting 37% of cloud GPU environments. This is the execution harness / firmware boundary.

4. **No verified GPU drivers exist**: seL4's sDDF achieved the first verified Ethernet driver (Pancake language, 2025). GPU drivers are orders of magnitude more complex and remain unverified.

5. **UEFI/Secure Boot is structurally broken**: CVE-2024-7344 shows signed-but-vulnerable binaries bypass Secure Boot. LogoFAIL remains unpatched on hundreds of devices. The trust chain is fragile.

6. **Formal methods opportunities are clear**: PA-Boot (Isabelle/HOL), Pancake/Viper verified drivers, UPPAAL model checking for boot code, GPUVerify for kernel correctness. These are existence proofs that FM can address this layer.

7. **Attestation is rapidly standardizing**: NVIDIA NRAS, Intel Trust Authority, RFC 9683 for TPM, TCG specs for TPM firmware attestation, CNCF combined TPM+TEE attestation. But formal verification of attestation protocols is still nascent.
