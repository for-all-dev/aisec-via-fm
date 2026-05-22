# Missing Citations Checklist

_From the prose audit of 2026-04-05. Each entry names the file, line, the claim that needs a citation, and what kind of source to look for. Check off as you add them to `paper/common/refs.bib` and wire the `@cite-key` into the `.typ` file._

_Audit pass 2026-05-22: every entry below was re-checked against the current `.typ` files. All previously-unchecked items are already wired in or have been resolved by prose revision. Two prose decisions were made (see § Notes from 2026-05-22 audit at the bottom)._

## paper/stack/execution-harness.typ

- [x] **L14/22**: "SafeTensors or GGUF, that have had their own history of arbitrary-code-execution bugs" — prose was tightened: GGUF cites `@ggml2025gguf` ("memory-corruption bugs"); SafeTensors now cites `@trailofbits2023safetensors` ("no critical flaws"). The original "ACE bugs" framing was inaccurate for SafeTensors and was corrected
- [x] **L16/24**: LiteLLM mention — wired via `@futuresearch2026litellm` at `software-framework.typ:47` (dependency supply chain section, where the prose now lives)

## paper/stack/software-framework.typ

- [x] **L14**: "LLVM's MLIR infrastructure had multiple memory-management vulnerabilities in 2023 (CVE-2023-29932 through CVE-2023-29939)" — `@cve2023mlir`
- [x] **L22**: "a 2025 XLA:TPU miscompilation in the approximate top-k operation" — `@anthropic2025postmortem`
- [x] **L16**: "CompCert closed for C" — `@leroy2009compcert`
- [x] **L22**: "CVE-2025-32434 (CVSS 9.3)" — `@cve2025pytorch`
- [x] **L32**: "JFrog found three zero-day bypasses in the scanner itself" — `@jfrog2025picklescan`
- [x] **L32**: "Approximately 100 malicious models with real reverse-shell payloads have been found on Hugging Face's model hub" — prose revised: replaced the explicit "100 malicious models" headline number with the more specific `@reversinglabs2025nullifai` (nullifAI 7z-pickle technique), which documents the evasion mechanism rather than a count. The JFrog "baller423 reverse-shell" finding is implicitly covered via `@jfrog2025picklescan`; if the headline count matters, the source is JFrog's "Data Scientists Targeted by Malicious Hugging Face ML Models with Silent Backdoor" post (Feb 2024)
- [x] **L22**: "CVE-2024-3660 showed that the `safe_mode` fix could be bypassed via a downgrade attack" — `@cve2024keras`
- [x] **L34**: "An independent security audit found no critical flaws" (re: SafeTensors) — `@trailofbits2023safetensors`

## paper/stack/orchestration-cloud.typ

- [x] **L10**: "NVIDIA container toolkit... CVE-2024-0132, CVSS 9.0" — `@cve2024nvcontainer`
- [x] **L10**: "33% of cloud environments per Wiz's estimate" — folded into `@cve2024nvcontainer` note
- [x] **L10**: "runc, had its own escape (CVE-2024-21626)" — `@cve2024runc`
- [x] **L12**: "CVE-2023-49935" (Slurm MUNGE bypass) — `@cve2023slurmmunge`
- [x] **L12**: "CVE-2022-29501" (Slurm PMI2 socket write) — `@cve2022slurmpmi`
- [x] **L12**: "CVE-2017-15566" (Slurm SPANK priv esc) — `@cve2017slurmspank`
- [x] **L14**: "ShadowRay campaign (CVE-2023-48022, CVSS 9.8)" — `@cve2023shadowray`
- [x] **L46**: "researchers documented an attack chain where compromised credentials reached cloud administrator privileges in eight minutes, traversing 19 IAM roles" — `@sysdig2026aiattackchain` (Sysdig Threat Research Team report on the Nov 2025 LLM-assisted AWS intrusion)
- [x] **L40**: "PoisonGPT demonstration" — `@mithril2023poisongpt`
- [x] **L42**: "GitGuardian's 2025 report found 23.8 million secrets leaked in public GitHub repositories" — `@gitguardian2025secrets`

## paper/stack/firmware-lowlevel.typ

- [x] **L13**: "Google Project Zero's 2021 KVM breakout via AMD SEV" — `@wilhelm2021epyckvm` (note: actually KVM/SVM nested virtualization, not SEV; prose was tightened to reflect this)
- [x] **L12**: "Trail of Bits demonstrated this with LeftoverLocals (CVE-2023-4969)" — `@cve2023leftoverlocals`
- [x] **L15**: "NVBleed attack (March 2025)" — `@zhang2025nvbleed`
- [x] **L17**: "AMD's SEV-TIO extension" — `@amd2023sevtio`
- [x] **L18**: "CVE-2024-0126 (privilege escalation in the display driver)" — `@cve2024nvprivesc`
- [x] **L18**: "CVE-2024-0107 (out-of-bounds read leading to code execution)" — `@cve2024nvoobread`
- [x] **L21**: "nine vulnerabilities in the CUDA toolkit found by Palo Alto's Unit 42" — `@unit42_cudatoolkit`
- [x] **L20**: "CVE-2022-21819" (Jetson PCIe DMA bypass) — `@cve2022nvjetsondma`
- [x] **L30**: "BlackLotus bootkit (2023) exploited CVE-2022-21894" — `@cve2022blacklotus`
- [x] **L32**: "Binarly disclosed seven vulnerabilities in Supermicro BMC firmware (CVE-2023-40284 through CVE-2023-40290)" — `@cve2023supermicrobmc`
- [x] **L34**: "2022 LAPSUS$ breach of NVIDIA resulted in the theft of two code-signing certificates" — `@lapsus2022nvidia`

## paper/stack/hardware-supply-chain.typ

- [x] **L14**: "CAD-Base" work — `@basu2019cadbase` (note: original audit said "Rajendran et al." but the paper's first author is Basu — Ramesh Karri's group at NYU. Prose updated to "Basu et al.")
- [x] **L18**: "Intel adopted formal methods in earnest after the 1994 Pentium FDIV bug ($475 million recall)" — `@harrison2003fvatintel`
- [x] **L16**: "ARM's ISA-Formal framework" — `@reid2016isaformal`
- [x] **L20**: "YosysHQ's riscv-formal" — `@yosyshq_riscvformal`
- [x] **L20**: "OpenHW Group's CORE-V-VERIF" — `@openhw_corevverif`
- [x] **L20**: "MIT's Riscy processors" / Kami — `@choi2017kami`
- [x] **L26**: "Maia et al. (USENIX Security 2022)" — `@maia2022gpupowercable`
- [x] **L26**: "'Graphics Peeping Unit' work (IEEE S&P 2022)" — `@zhan2022gpupeeping`
- [x] **L32**: "DARPA estimated counterfeiting costs the electronics industry $170 billion annually" — **prose revised**. The $170B number could not be pinned to a primary source; the closest defensible figure is SIA's $7.5B/year U.S. industry estimate. Prose now reads "$7.5 billion a year in lost revenue" and cites `@sia2013anticounterfeit`. The IHS $169B "potential annual risk" figure from 2012 is a different (broader) metric and was not adopted
- [x] **L34**: "TSMC fabricates over 90% of the world's most advanced chips" — `@sia2021supplychain`

## paper/problems/edge-policy-verification.typ

- [x] **L12**: "JWT algorithm confusion (CVE-2015-9235)" — `@cve2015jwtalg`
- [x] **L24**: "ProVerif or Tamarin" — `@blanchet2001proverif`, `@meier2013tamarin`

## paper/problems/scheduler-cotenancy.typ

- [x] **L12**: "well-documented cache side-channel attacks (Flush+Reload, Prime+Probe)" — `@yarom2014flushandreload`, `@liu2015llcsidechannel`

## paper/problems/weight-integrity.typ

- [x] **L22**: "translation validation in the style of Pnueli, Siegel, and Singerman (1998)" — `@pnueli1998translationvalidation`
- [x] **L22**: "Fiat Cryptography" — `@erbsen2019fiatcrypto`

## paper/problems/advro.typ

- [ ] **L16**: The `@demoura2026watchersprovers` cite is there but the surrounding TODOs suggest more citations needed once Jason/James write up the soundness bugs section

## paper/problems/sampler-verification.typ

- [x] **L18**: "PRISM or Storm" — `@kwiatkowska2011prism`, `@dehnert2017storm`

---

## Notes from 2026-05-22 audit

Two prose decisions were made while reconciling the checklist with the current `.typ` files. Both are flagged here because they trade a flashy headline number for a defensible one:

1. **`hardware-supply-chain.typ` L32 — "$170B counterfeit" → "$7.5B".** The $170B/year figure circulates widely (sometimes attributed to DARPA, sometimes to IHS) but no primary source pins it to "annual cost to the electronics industry." IHS's 2012 number is $169B in "potential annual risk" across the five most-counterfeited categories, which is a market-exposure estimate, not a realised cost. SIA's $7.5B is the cleanest defensible primary source. If you'd prefer to keep the larger framing, the right move is to soften the language ("tens of billions in annual market exposure") and cite IHS — but the bib entry for that would still need to be added.

2. **`software-framework.typ` L32 — "~100 malicious models" headline.** The JFrog Feb 2024 "Data Scientists Targeted" post is the source for the ~100 count, but the more substantively-interesting story is the nullifAI evasion mechanism (`@reversinglabs2025nullifai`) and the PickleScan bypasses (`@jfrog2025picklescan`). Current prose leads with the mechanism and lets the count stay implicit. If you want to restore the explicit number, add a `@jfrog2024huggingfacebackdoor` entry pointing at https://jfrog.com/blog/data-scientists-targeted-by-malicious-hugging-face-ml-models-with-silent-backdoor/.

One stale claim to double-check:

3. **`firmware-lowlevel.typ` L13** previously said "KVM breakout via AMD SEV." The Project Zero writeup is actually a KVM breakout via AMD `SVM` (nested virtualization), not SEV. Current prose appears to have been corrected ("AMD `SVM` nested virtualization"), but worth a second pair of eyes.
