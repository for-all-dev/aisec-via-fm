# Missing Citations Checklist

_From the prose audit of 2026-04-05. Each entry names the file, line, the claim that needs a citation, and what kind of source to look for. Check off as you add them to `paper/common/refs.bib` and wire the `@cite-key` into the `.typ` file._

## paper/stack/execution-harness.typ

- [ ] **L14**: "SafeTensors or GGUF, that have had their own history of arbitrary-code-execution bugs" — need CVE numbers or advisories for SafeTensors/GGUF deserialization bugs
- [ ] **L16**: `TODO: incorporate this somewhere https://futuresearch.ai/blog/litellm-pypi-supply-chain-attack/` — this is an explicit TODO with a URL ready to cite

## paper/stack/software-framework.typ

- [x] **L14**: "LLVM's MLIR infrastructure had multiple memory-management vulnerabilities in 2023 (CVE-2023-29932 through CVE-2023-29939)" — `@cve2023mlir`
- [ ] **L14**: "a 2025 XLA:TPU miscompilation in the approximate top-k operation" — Google bug tracker, XLA changelog, or the commit that fixed it
- [ ] **L16**: "CompCert closed for C" — Leroy, Xavier. "Formal verification of a realistic compiler." CACM 2009 (or the original POPL 2006 paper)
- [x] **L22**: "CVE-2025-32434 (CVSS 9.3)" — `@cve2025pytorch`
- [ ] **L22**: "JFrog found three zero-day bypasses in the scanner itself" — JFrog blog post (search "JFrog PickleScan bypass" or "JFrog PyTorch pickle")
- [ ] **L22**: "Approximately 100 malicious models with real reverse-shell payloads have been found on Hugging Face's model hub" — JFrog or HF security team blog post documenting the count
- [x] **L22**: "CVE-2024-3660 showed that the `safe_mode` fix could be bypassed via a downgrade attack" — `@cve2024keras`
- [ ] **L24**: "An independent security audit found no critical flaws" (re: SafeTensors) — the actual audit report (likely Trail of Bits or similar, published on HF's GitHub)

## paper/stack/orchestration-cloud.typ

- [x] **L10**: "NVIDIA container toolkit... CVE-2024-0132, CVSS 9.0" — `@cve2024nvcontainer`
- [x] **L10**: "33% of cloud environments per Wiz's estimate" — folded into `@cve2024nvcontainer` note
- [x] **L10**: "runc, had its own escape (CVE-2024-21626)" — `@cve2024runc`
- [x] **L12**: "CVE-2023-49935" (Slurm MUNGE bypass) — `@cve2023slurmmunge`
- [x] **L12**: "CVE-2022-29501" (Slurm PMI2 socket write) — `@cve2022slurmpmi`
- [x] **L12**: "CVE-2017-15566" (Slurm SPANK priv esc) — `@cve2017slurmspank`
- [x] **L14**: "ShadowRay campaign (CVE-2023-48022, CVSS 9.8)" — `@cve2023shadowray`
- [ ] **L38**: "researchers documented an attack chain where compromised credentials reached cloud administrator privileges in eight minutes, traversing 19 IAM roles" — likely a Wiz, Orca, or Palo Alto Unit 42 report from 2025; search for "IAM privilege escalation 19 roles 8 minutes"
- [ ] **L40**: "PoisonGPT demonstration" — Mithril Security blog post, 2023
- [ ] **L42**: "GitGuardian's 2025 report found 23.8 million secrets leaked in public GitHub repositories" — GitGuardian State of Secrets Sprawl 2025 report

## paper/stack/firmware-lowlevel.typ

- [ ] **L10**: "Google Project Zero's 2021 KVM breakout via AMD SEV" — Project Zero blog post or the specific CVE
- [x] **L12**: "Trail of Bits demonstrated this with LeftoverLocals (CVE-2023-4969)" — `@cve2023leftoverlocals`
- [ ] **L12**: "NVBleed attack (March 2025)" — the NVBleed paper (likely arXiv or a security conference)
- [ ] **L14**: "AMD's SEV-TIO extension" — AMD whitepaper or PCI-SIG TDISP spec
- [x] **L18**: "CVE-2024-0126 (privilege escalation in the display driver)" — `@cve2024nvprivesc`
- [x] **L18**: "CVE-2024-0107 (out-of-bounds read leading to code execution)" — `@cve2024nvoobread`
- [ ] **L18**: "nine vulnerabilities in the CUDA toolkit found by Palo Alto's Unit 42" — Unit 42 blog post
- [x] **L20**: "CVE-2022-21819" (Jetson PCIe DMA bypass) — `@cve2022nvjetsondma`
- [x] **L30**: "BlackLotus bootkit (2023) exploited CVE-2022-21894" — `@cve2022blacklotus`
- [x] **L32**: "Binarly disclosed seven vulnerabilities in Supermicro BMC firmware (CVE-2023-40284 through CVE-2023-40290)" — `@cve2023supermicrobmc`
- [ ] **L34**: "2022 LAPSUS$ breach of NVIDIA resulted in the theft of two code-signing certificates" — news coverage (BleepingComputer, The Record) or NVIDIA's own disclosure

## paper/stack/hardware-supply-chain.typ

- [ ] **L12**: "Rajendran et al. demonstrated in their 'CAD-Base' work" — Rajendran et al., probably "Is Split Manufacturing Secure?" or their EDA trojan insertion paper; search "Rajendran CAD hardware trojan EDA"
- [ ] **L16**: "Intel adopted formal methods in earnest after the 1994 Pentium FDIV bug ($475 million recall)" — Harrison, "Formal Verification at Intel" or Seger/Bryant's retrospective
- [ ] **L16**: "ARM's ISA-Formal framework" — Reid et al., "End-to-End Verification of Processors with ISA-Formal," CAV 2016
- [ ] **L18**: "YosysHQ's riscv-formal" — YosysHQ GitHub repo or Clifford Wolf's documentation
- [ ] **L18**: "OpenHW Group's CORE-V-VERIF" — OpenHW Group GitHub or their verification strategy doc
- [ ] **L18**: "MIT's Riscy processors" — Riscy Expedition / Kami project, likely Choi et al. MICRO 2017 or the Kami ICFP 2017 paper
- [ ] **L26**: "Maia et al. (USENIX Security 2022)" — full bib entry needed; search "GPU power cable magnetic flux neural network USENIX 2022"
- [ ] **L26**: "'Graphics Peeping Unit' work (IEEE S&P 2022)" — full bib entry needed; search "Graphics Peeping Unit electromagnetic GPU IEEE S&P 2022"
- [ ] **L30**: "DARPA estimated counterfeiting costs the electronics industry $170 billion annually" — DARPA SHIELD program page or the IPC/ERAI counterfeit report that sources this number
- [ ] **L32**: "TSMC fabricates over 90% of the world's most advanced chips" — SIA report or a specific industry analysis (this number is widely cited but worth pinning to a source)

## paper/problems/edge-policy-verification.typ

- [x] **L12**: "JWT algorithm confusion (CVE-2015-9235)" — `@cve2015jwtalg`
- [ ] **L22**: "ProVerif or Tamarin" — Blanchet, "ProVerif" and Meier et al., "Tamarin Prover" (tool papers)

## paper/problems/scheduler-cotenancy.typ

- [ ] **L12**: "well-documented cache side-channel attacks (Flush+Reload, Prime+Probe)" — Yarom & Falkner, "FLUSH+RELOAD," USENIX Security 2014; Liu et al., "Last-Level Cache Side-Channel Attacks are Practical," IEEE S&P 2015

## paper/problems/weight-integrity.typ

- [ ] **L22**: "translation validation in the style of Pnueli, Siegel, and Singerman (1998)" — Pnueli, Siegel, Singerman, "Translation Validation," TACAS 1998
- [ ] **L22**: "Fiat Cryptography" — Erbsen et al., "Simple High-Level Code for Cryptographic Arithmetic," IEEE S&P 2019

## paper/problems/advro.typ

- [ ] **L16**: The `@demoura2026watchersprovers` cite is there but the surrounding TODOs suggest more citations needed once Jason/James write up the soundness bugs section

## paper/problems/sampler-verification.typ

- [ ] **L18**: "PRISM or Storm" — Kwiatkowska et al., "PRISM 4.0" (tool paper); Dehnert et al., "A Storm is Coming" (STTT 2017)
