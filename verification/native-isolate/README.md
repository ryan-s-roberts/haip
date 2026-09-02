# HAIP protocol verification

This standalone project models and verifies selected compatibility and safety properties
of HAIP 2. The reviewed target is
[HAIP PR #5](https://github.com/haiprotocol/haip/pull/5), fixed at base
`f04a2f362ee02e09fd23819a5409e78b82a7be8b` and head
`c02bf330324b0ec8385a8438d112c258caec6161`.

The project is independent of the HAIP implementation. It records external evidence,
documents protocol-level findings, and hosts executable Quint models and tests.
It does not certify a deployment, implementation, package, identity provider, storage
system, or external effect.

## Scope

- HAIP 2 draft review, execution, trust and reference behavior in PR #5;
- the native [HAIP Agent UI profile](review/haip-agent-ui-profile.md), including its
  View↔Host `haip/ui.*` methods over a generic JSON-RPC 2.0 `postMessage` envelope:
  `haip/ui.initialize`, `haip/ui.initialized`, `haip/ui.input`, `haip/ui.result`,
  `haip/ui.propose`, and `haip/ui.teardown`, with profile-fixed
  `localProposal: true`;
- comparison-only / historical provenance analysis against stable MCP Apps
  `2026-01-26`, MCP core and Tasks `2026-07-28`, and HITL v0.8 at commit
  `655eba84932669af057e3cd9cacb1c94ae51ae65`.

HAIP is explicitly **not** an MCP server, MCP client, MCP transport, MCP Tasks
implementation, or MCP MRTR implementation. Its UI profile defines native HAIP message
names and capabilities. There is no `tools/call`, tool-name field, or `serverTools`
surface. Stable MCP Apps is comparison and historical provenance evidence only; HAIP
does not adopt Apps message shapes and claims no Apps conformance. HAIP discovery,
review, confirmation, authorization, execution, and transport remain native.

Rolling MCP Apps drafts and legacy `mcp-ui` are deliberately excluded. Source identity,
authority and precedence are locked in
[`sources/sources.lock.json`](sources/sources.lock.json). The detailed analysis is
[`review/protocol-compatibility.md`](review/protocol-compatibility.md); the normative UI
contract is [`review/haip-agent-ui-profile.md`](review/haip-agent-ui-profile.md).

HAIP v1 is historical for this project. PR #5 replaces it with the incompatible HAIP 2
draft and retains v1 only as an archive; v1 streaming/chat contracts are not the current
review target.

## Verification commands

Install the pinned Quint CLI and run the public verification interface:

```sh
npm install
npm run check
npm test
npm run simulate
npm run verify
```

- `check` typechecks the complete composed Quint model.
- `test` runs deterministic protocol and discrepancy traces.
- `simulate` explores 500 deterministic pseudorandom traces (seed
  `0x5eed2026`) of up to 30 transitions while checking `haipSafety` and
  `boundedState`.
- `verify` asks Apalache to check `haipSafety` through two transitions.

The bounded check is evidence, not a proof for arbitrary depth. The state domains are
finite and intentionally abstract cryptography, browser enforcement, storage
transactions, and network delivery into guarded transitions.

## Reading results

The review separates verified source facts, native requirements, interpretation, and
comparison-only evidence. Findings use `native HAIP`, `historical note`, `narrowed`,
`omitted`, `defect`, and `underspecified`. Historical Apps method names and pinned
implementation shapes are never treated as normative HAIP wire requirements or
Apps conformance.

The Quint entry point is [`quint/scenarios.qnt`](quint/scenarios.qnt). Model-checking
results, assumptions, bounds, and tooling caveats are recorded in
[`review/model-check-results.md`](review/model-check-results.md).
