# HAIP 2 protocol compatibility review

Review target: [HAIP PR #5](https://github.com/haiprotocol/haip/pull/5), base
[`f04a2f3`](https://github.com/haiprotocol/haip/commit/f04a2f362ee02e09fd23819a5409e78b82a7be8b),
head [`c02bf33`](https://github.com/haiprotocol/haip/commit/c02bf330324b0ec8385a8438d112c258caec6161).
Locked evidence and its role are recorded in
[`sources/sources.lock.json`](../sources/sources.lock.json). The approved native UI
contract is [`haip-agent-ui-profile.md`](haip-agent-ui-profile.md).

## Verdict

HAIP is an independent approval and execution protocol. It is explicitly **not** an MCP
server, MCP client, MCP transport, MCP Tasks implementation, or MCP MRTR implementation.
It does not need those surfaces for the approved architecture and must not imply that it
implements them.

The Agent UI profile is a native HAIP View↔Host protocol. It uses JSON-RPC 2.0 only as a
generic `postMessage` envelope. Method names, capabilities, identity, trust, envelope,
lifecycle, authority, and effect semantics are native HAIP. Stable MCP Apps `2026-01-26`
is retained as historical provenance and comparison evidence; HAIP does not adopt Apps
message names and claims no Apps conformance.

Modern MCP core and Tasks `2026-07-28`, and HITL v0.8, are retained only as comparison
evidence. Their similar concepts do not define HAIP behavior and are not implementation
recommendations.

The cutover has four decisive boundaries:

1. A trusted Host verifies an immutable request/bundle/source envelope before loading
   producer code into an opaque, deny-all sandbox.
2. The View receives one input snapshot and one result snapshot and may invoke one
   Host-local proposal operation via `haip/ui.propose`.
3. Proposal, confirmation, authorization, and effect are separate states with no
   implicit promotion between them.
4. Controlled teardown uses a correlated `haip/ui.teardown` request; crashes discard
   unconfirmed state; trusted native UI always remains available.

## Method and labels

- **Verified source fact** is stated by or directly observable in a locked source.
- **Interpretation** is this review's compatibility or security conclusion.
- **Native requirement** is part of the approved HAIP profile, not an external claim.
- **Comparison only** identifies a concept that is useful for contrast but imposes no
  HAIP implementation requirement.

The labels `native HAIP`, `historical note`, `narrowed`, `omitted`, `defect`, and
`underspecified` replace broad conformance language where no external conformance is
claimed. Similar security intent is not wire conformance. Historical notes about the
pinned implementation's Apps-shaped methods are not normative HAIP requirements.

## Architecture requirements

### Native envelope and trust

The Host must verify one immutable approval envelope binding the HAIP request ID,
request revision and digest, bundle ID, bundle revision and digest, producer identity,
agent-system identity, tenant, and configured sandbox origin. Input and result are
complete frozen snapshots. No producer metadata or later lookup may mutate that
binding.

The Host is trusted HAIP code and owns authentication, envelope verification, native
rendering, schema validation, confirmation, and lifecycle. The View is untrusted code
and is never an authority. It runs in an opaque-origin, scripts-only inner frame with no
network, credentials, storage, forms, navigation, popups, downloads, or direct HAIP
access. The Host applies a fixed deny-all policy; producer CSP metadata cannot widen it.

Both bridge boundaries require the exact expected `WindowProxy` and exact configured
origin where an origin exists. The opaque inner frame is identified by its exact source
window, never by accepting textual `"null"` as identity. Wildcards and suffix,
substring, inherited, or last-seen-origin checks are forbidden.

### Initialization and snapshots

The only allowed initialization sequence is the native View→Host `haip/ui.initialize`
request, the correlated Host response, and the View→Host `haip/ui.initialized`
notification. The request and response negotiate only the fixed native profile and
`localProposal: true`. This is not MCP core initialization or negotiation. The Host
then sends one complete `haip/ui.input`, followed by one complete `haip/ui.result`. It
sends no deltas, refreshes, subscriptions, or later mutations.

Every request ID is unique within one View instance. Responses must match an outstanding
ID exactly. Unknown, duplicate, completed, previous-instance, malformed, and replayed
IDs are rejected without changing approval state.

### One local proposal operation

The View may send `haip/ui.propose` only. Parameters are a schema-valid candidate object
bound to the immutable envelope; there is no tool name field. The operation is not an
MCP tool and is not forwarded to a server, producer, executor, or external effect.
Arguments are size-bounded, schema-validated, and bound to the immutable envelope.

Capability advertisement is profile-fixed `localProposal: true` only. External concepts
such as Apps `serverTools` or `tools/call` are comparison-only historical notes about
the pinned implementation; they are not HAIP capabilities.

The security invariant is absolute:

```text
proposal != confirmation != authorization != effect
```

A proposal may pre-fill trusted native controls. Confirmation is a separate explicit
human act in Host-owned UI over the exact frozen candidate. A confirmation creates only
the native decision allowed by the request purpose. Authorization separately requires
HAIP grant, claim, and fresh-admission rules where applicable. Only an external executor
can produce an effect. No UI message proves confirmation, authorization, effect, or
external cancellation.

### Lifecycle and fallback

For controlled unmount, replacement, or navigation, the Host sends `haip/ui.teardown`,
correlates its response, waits for a short bounded grace period, and then destroys the
View. Timeout or malformed acknowledgement still ends in destruction and grants no
authority.

An abrupt frame, renderer, process, or page failure is a crash, not a graceful teardown.
The Host discards all outstanding IDs and unconfirmed proposals. A replacement is a new
instance and repeats envelope verification and initialization. Trusted native rendering
and response controls remain available on initialization failure, policy violation,
unsupported content, crash, or teardown failure.

## Stable Apps feature classification (comparison / provenance only)

Stable MCP Apps `2026-01-26` is not a normative source for HAIP message names. The table
below records provenance and contrast against the native profile; Apps features create
no HAIP implementation requirement.

| Stable Apps feature | Review label | Relation to native HAIP |
|---|---|---|
| JSON-RPC 2.0 envelopes and ID correlation | comparison / retained envelope | HAIP keeps JSON-RPC 2.0 as a generic `postMessage` envelope; method names are native. |
| `ui/initialize` and `ui/notifications/initialized` | historical provenance | Replaced by native `haip/ui.initialize` and `haip/ui.initialized`. |
| `ui/notifications/tool-input` and `ui/notifications/tool-result` | historical provenance | Replaced by native `haip/ui.input` and `haip/ui.result` (complete one-shot snapshots). |
| `tools/call` + tool name | historical provenance | Replaced by native `haip/ui.propose` with a schema-valid candidate and no tool name field. |
| `ui/resource-teardown` | historical provenance | Replaced by native `haip/ui.teardown`. |
| `serverTools` | historical note / omitted | Semantically false for HAIP; native advertisement is `localProposal: true` only. |
| `ui://`, resource metadata and `resources/read` | omitted | Native immutable bundle registry and digest binding are authoritative. |
| producer `_meta.ui.csp` | omitted | Fixed deny-all policy cannot be widened. |
| proxy pass-through and arbitrary methods | omitted | Anything outside the native allowlist is forbidden. |
| links, prompts, resources, logging, context updates and general tools | omitted | No such View authority exists. |
| optional size, streaming and subscription messages | omitted | One immutable render session has no updates. |
| Apps capability negotiation | comparison only | HAIP uses a fixed named profile, not MCP negotiation. |
| Apps conformance claim | omitted | Historical comparison establishes no external conformance. |

## Requirement-level findings

| ID | Classification | Finding |
|---|---|---|
| UI-1 | native HAIP | The envelope binds immutable bundle/digest/revision and request/digest/revision to producer, agent system, tenant, and origin before code executes. |
| UI-2 | native HAIP | Trusted Host and opaque untrusted View are different trust domains; exact source and origin checks are mandatory. |
| UI-3 | native HAIP | The six allowed methods are native `haip/ui.*` names with fixed ordering; Apps method names are not part of the normative contract. |
| UI-4 | native HAIP | `haip/ui.propose` is the sole local proposal operation; capability advertisement is `localProposal: true` only. |
| UI-5 | native HAIP | Request IDs correlate one View instance; unknown, duplicate and replayed IDs cannot mutate state. |
| UI-6 | native HAIP | Fixed deny-all policy intentionally replaces producer-defined CSP and domain permissions. |
| UI-7 | native HAIP | Native fallback is always available and a View crash discards unconfirmed state. |
| UI-8 | native HAIP | Proposal, confirmation, authorization, and effect remain absolutely separate. |
| APP-H1 | historical note / pinned implementation | The pinned host historically used Apps-shaped `tools/call`, `serverTools`, and tool-input/result names. Those shapes are not normative HAIP requirements after the native cutover. |
| APP-H2 | historical note / no conformance claim | Native bundle registration replaces `ui://`, resource metadata, and `resources/read`; HAIP was never a conforming stable Apps host and does not claim to become one. |
| APP-H3 | historical note / pinned implementation | Filtering at the HAIP boundary differs from stable Apps proxy pass-through. This is an intentional native security rule, not an Apps defect to remove. |
| APP-H4 | historical note / pinned implementation defect | The pinned host closes on `pagehide` without a separate correlated teardown exchange. Full cutover requires graceful `haip/ui.teardown` while retaining abrupt-crash handling. |
| APP-H5 | historical note / pinned implementation defect | Advertising generic `serverTools: {}` in the pinned implementation is broader and semantically different from profile-fixed `localProposal: true`. |
| MCP-C1 | comparison only | MCP core `2026-07-28` per-request metadata, `server/discover`, transports, elicitation, cancellation, and MRTR are not HAIP surfaces. Their absence is not a HAIP defect. |
| TASK-C1 | comparison only | HAIP durable review resembles some Tasks lifecycle concepts but implements no Tasks negotiation, methods, result shapes, status model, or cancellation. No mapping is proposed. |
| MRTR-C1 | comparison only | HAIP has multiple application-level steps but does not emit `InputRequiredResult`, carry `requestState`, or retry an MCP method. It is not MRTR. |
| HITL-C1 | comparison only / pinned adapter defect | The pinned adapter's `spec_version: "0.8"` does not satisfy HITL v0.8 signed bearer URL, no-login, and action semantics. Native HAIP identity must not be weakened to preserve that label. |
| SPEC-1 | underspecified | The public response-schema profile still needs a positive dialect, vocabulary, numeric model, and deterministic resource limits. |
| SPEC-2 | underspecified | Registrable-site separation still needs a fixed PSL/IDNA algorithm and fail-closed behavior. |
| SPEC-3 | underspecified | Trust-manifest validation, key-ID scope, revocation-time semantics, and historical evidence remain partly operational prose. |
| EXEC-1 | native safety requirement | A UI proposal or decision cannot grant execution. Effectful execution separately requires native authority, occurrence consumption, fresh admission, and executor safeguards. |

## MCP core, MRTR, and Tasks: comparison only

Modern MCP core `2026-07-28` is stateless at the protocol-request level and defines
per-request metadata, `server/discover`, transports, elicitation, cancellation, and
MRTR. Tasks `2026-07-28` defines extension negotiation, durable task handles, polling,
mid-flight input, updates, statuses, and cooperative cancellation.

HAIP defines none of those MCP surfaces. Its native HTTP and browser protocols must not
be wrapped in MCP terminology merely because both systems have capabilities, pending
work, user input, or cancellation. In particular:

- a HAIP request is not an MCP request;
- a HAIP review is not an MRTR `input_required` result;
- a HAIP durable request is not an MCP Task;
- a HAIP request ID is not a Task handle;
- HAIP invalidation is not MCP request or Task cancellation;
- the View↔Host `haip/ui.initialize` is not MCP core initialization;
- the View's `haip/ui.propose` operation is not an MCP server tool.

No `server/discover`, MRTR, Tasks, transport, or MCP adapter implementation is
recommended by this review. A future independently scoped gateway could translate
protocols, but it would be a separate product with its own trust and conformance
analysis, not part of this profile.

## HITL comparison

Pinned HITL v0.8 treats a signed review URL as a browser credential and says no login is
required. Native HAIP treats link possession as non-authoritative and requires an
operator-established human identity plus eligibility and separation checks. Those are
different threat models.

The current native design must retain HAIP identity and authority rules. The pinned
adapter should not emit an unqualified HITL v0.8 identity for a non-v0.8 object.
Removing that label or placing strict translation in a separately scoped gateway is
honest; changing native HAIP to bearer-link authority is not.

The pinned HITL MCP binding is informative and comparison-only. It predates final MCP
`2026-07-28` and cannot define HAIP behavior or establish MCP conformance.

## Security properties and residual risks

Strong native properties:

- immutable source, request, bundle, revision, and digest binding;
- authentication and eligibility outside the untrusted View;
- exact-origin/source enforcement and fixed deny-all sandboxing;
- one-shot snapshots with no mutable renderer data source;
- proposal-only View authority and trusted native confirmation;
- independent decision, authority, admission, execution, and evidence states;
- replay rejection and permanent occurrence-consumption rules;
- native fallback and fail-closed lifecycle behavior;
- discovery remains separate from trust.

Residual risks:

- the trusted Host and service can share an administrative failure domain;
- signatures prove bytes and configured identity, not comprehension or UI fidelity;
- native controls must make the bound digest/revision/source intelligible to the human;
- browser and origin isolation depend on correctly deployed separate sites and headers;
- crash paths must not preserve proposals or request IDs accidentally;
- external effects remain outside what a UI or signed decision can prove;
- WORM administration, key recovery, and deployed storage guarantees require operational
  evidence beyond this static review.

## Cutover requirements

1. Publish and bind the exact profile identifier and native `haip/ui.*` method set
   independently of renderer package versions.
2. Verify the complete native envelope before View creation and on every native
   confirmation path.
3. Advertise only `localProposal: true`; reject every non-profile operation and any
   tool-name or `tools/call` shaped message.
4. Enforce exact source/origin checks, per-instance ID correlation, replay rejection,
   one-shot `haip/ui.input` / `haip/ui.result` ordering, message limits, and fixed
   deny-all policy.
5. Implement correlated graceful `haip/ui.teardown` for controlled removal and
   separately test abrupt frame, page, and process crashes.
6. Keep trusted native display and confirmation controls available in every failure mode.
7. Test that a proposal cannot confirm, a confirmation cannot authorize, an
   authorization cannot prove an effect, and no UI message can cross those boundaries.
8. Remove claims that HAIP implements MCP, MCP Apps, MRTR, Tasks, or HITL v0.8 where the
   complete external contract is not implemented. Treat Apps method names as historical
   provenance only.

## Scope boundary

This is a static protocol and source review. It does not claim runtime verification,
production penetration testing, deployment acceptance, package provenance, or external
effect correctness. The supplied base and head commits, not a moving branch or merge
ref, define the reviewed implementation. External MCP, MCP Apps, and HITL evidence is
comparison-only / historical provenance. Stable Apps `2026-01-26` does not supply
normative HAIP message shapes after the native isolate messaging cutover.
