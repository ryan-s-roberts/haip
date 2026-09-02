module hitl_v08_adapter {
  import domain.* from "./domain"

  // v0.8 actions are encoded as 0=pending, 1=approve, 2=reject.
  // A conforming adapter has an explicit decision and never silently defaults.
  pure def hitlDecisionExplicit(s: str -> int): bool =
    s.get("hitl") == ONE or s.get("hitl") == TWO

  pure def hitlConforming(s: str -> int): bool =
    (s.get("hitl") != ZERO).implies(all {
      hitlDecisionExplicit(s),
      s.get("hitlDefault") == ZERO,
      s.get("hitlAction") == s.get("hitl"),
    })

  pure def observedNonconformingHitl(s: str -> int): bool =
    s.get("hitlDefault") == ONE or s.get("hitlAction") != s.get("hitl")
}
