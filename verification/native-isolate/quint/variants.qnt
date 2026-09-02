module variants {
  type Variant = Normative | Implementation

  pure def isNormative(v: Variant): bool = v == Normative
  pure def permitsOutcomeWithoutAdmission(v: Variant): bool = v == Implementation
  pure def permitsMultipleAdmissions(v: Variant): bool = v == Implementation
  pure def permitsProposalFiltering(v: Variant): bool = v == Implementation
  // Implementation may falsely advertise methods beyond haip/ui.propose.
  pure def advertisesExtraProposalMethods(v: Variant): bool = v == Implementation
  pure def permitsUncontrolledTeardown(v: Variant): bool = v == Implementation
  pure def permitsHitlFallback(v: Variant): bool = v == Implementation
}
