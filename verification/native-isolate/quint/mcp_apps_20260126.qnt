module mcp_apps_20260126 {
  import domain.* from "./domain"

  // Non-normative comparative vocabulary projection only.
  // These predicates describe how native host/View events could be *projected*
  // onto January 2026 Apps wire vocabulary for contrast. They are never a
  // conjunct of normative HAIP safety and must not be read as Apps adoption.
  pure def comparativeAppsUiOrdering(s: str -> int): bool = all {
    (s.get("uiInitialize") == ONE).implies(
      s.get("host") == HOST_READY
        or s.get("host") == HOST_STOPPING
        or s.get("host") == HOST_STOPPED
        or s.get("host") == HOST_CRASHED),
    (s.get("uiInitialized") == ONE).implies(
      s.get("uiInitialize") == ONE),
  }

  pure def comparativeAppsSnapshotShape(s: str -> int): bool = all {
    s.get("inputSnapshotCount") <= ONE,
    s.get("resultSnapshotCount") <= ONE,
    (s.get("resultSnapshotCount") == ONE).implies(
      s.get("inputSnapshotCount") == ONE),
  }

  // Comparative only: native METHOD_PROPOSE projects onto the Apps-era local
  // proposal slot; the normative model uses haip/ui.propose directly.
  pure def comparativeAppsProposalVocabulary(s: str -> int): bool = all {
    (s.get("proposalAccepted") == ONE).implies(all {
      s.get("proposalMethod") == METHOD_PROPOSE,
      s.get("proposalResponseId") == s.get("proposalRequestId"),
      s.get("proposalSource") == SOURCE_EXACT,
      s.get("resultOrigin") == ORIGIN_EXACT,
    }),
    s.get("extraProposalMethods") == ZERO,
    (s.get("proposalProxy") == ONE).implies(
      s.get("proposalFiltered") == ZERO),
  }

  pure def comparativeAppsWireCompatible(s: str -> int): bool = all {
    comparativeAppsUiOrdering(s),
    comparativeAppsSnapshotShape(s),
    comparativeAppsProposalVocabulary(s),
    (s.get("host") == HOST_STOPPED).implies(
      s.get("controlledTeardown") == ONE),
  }
}
