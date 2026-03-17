# Memo from slack March 16th
## Nora:
> I guess very broadly how I think about it is as follows: 'verifying workloads' means verifying some property of interest about a workload. And to do so you need to verify it against some model of what is running that workload - which you could define at various different levels of software and hardware. Now, your verification claims about workloads will be more trustworthy the more confident you are that your assumption about the software/hardware it is running on is accurate with respect to what's actually happening. So the further down you go in the stack, in terms of having a correct/verified model of the dynamics (and/or the presence/absence of specific properties) at that layer, the more confident you are there aren't any 'leaky abstarctions' that an attacker could exploit.

> Not sure how helpful that is. In terms of what might add a lot of security value, I've recently thought a bit more about verifying (integrity and confidentiality) of the inference stack (eg vLLM). Things like
> - Can you verify no possible input (e.g. prompts) will cause buffer overflow or other malicious side effect
> - Can you verify you cannot “smuggle” additional data into the output except for what’s genuinely being output by your model
> - Send back a cryptographic attestation (e.g. hash, HMAC, …) of some property of interest (e.g. which model used, which prompt used, …) 
> - Can you verify that things cannot leak between users in certain ways?  (isolation / confidentiality guarantees in spite of optimisations around multi-user, batching, etc.
> - (probably also a couple of guarantees to protect against supply-chain attacks...)
> It's something we might try do some work on, but tbd.

> Another thoughts is that, in addition to securing/veriying specific bits, I htink there's a lot of leveraging in building better tooling to do this . AI opens the doors to being able to do way more and way more complex verification, at different levels of both hardware and software, so invetsing in that seems good. My programme at ARIA is making a bet on one way to do this. Ulyssean is also working on this with a specific focus on microelectronics.

> "verify the integration between systems"-- IMO the keyword (and one of the key technical bets we're making in the safegaurded AI programme) is assume-guarantee reasoning, which in turn requires you to be able to deal with compositionality well/in mathematically sound ways
> "re-verify a new stack"-- keyword here IMO is incremental proofing.
> keywords at least I would be looking for in projects that try to tackle something big here.

## Quinn: 
51% of 2025's "AI" CVEs are "Nvidia drivers, CUDA libraries, vGPU software, and DGX platforms" https://www.trendmicro.com/vinfo/us/security/news/threat-landscape/fault-lines-in-the-ai-ecosystem-trendai-state-of-ai-security-report (i found this asking gemini to estimate upside of hardening GPU drivers). Looks like mostly memory corruption and privilege escalation. Not happy! but seL4 is way better at isolation than anything else, and FM folks know a ton about memory safety.

- drivers: we semi I think kinda know how to formally verify a GPU driver https://trustworthy.systems/projects/pancake/ last time i asked claude how hard it would be it thought we're talking about 6M LoC. 7 figures is pretty bad! (i'm working on getting seL4 team involved) 
- CUDA: CUDA is just a programming language, so you defend it with semantics. We kinda (not really) know how to do this. 
vGPU: something like the Nova folks https://bluerocksec.gitlab.io/formal-methods/blogs/2025-11-18-NOVA-proof-spec/ Greg Malecha would love to chat
- DGX: the baseboard management controller is in some sense no stronger than its underlying kernel, so getting seL4 in deployment in real life could be good (difficult but not prohibitive, question mark?). Related: a docker first author tweeted that if WASI (server-side webassembly) existed back then, he would've not made docker (cuz it has so many isolation primitives for free) and i've been curious about if that'll show up.



