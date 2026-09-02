module discrepancies {
  import domain.* from "./domain"
  import composition.* from "./composition"
  import haip_impl.* from "./haip_impl"
  import hitl_v08_adapter.* from "./hitl_v08_adapter"

  // Positive witnesses preserved in native isolate-messaging vocabulary.
  val outcomeWithoutAdmissionWitness = observedOutcomeWithoutAdmission(st)
  val multipleAdmissionsWitness = observedMultipleAdmissions(st)
  val proposalFilteringWitness =
    st.get("proposalProxy") == ONE and st.get("proposalFiltered") == ONE
  // Capability-untruthful advertisement beyond haip/ui.propose.
  val extraProposalMethodsWitness = st.get("extraProposalMethods") == ONE
  val uncontrolledTeardownWitness =
    st.get("host") == HOST_STOPPED
      and st.get("controlledTeardown") == ZERO
      and st.get("crash") == ZERO
  val nonconformingHitlWitness = observedNonconformingHitl(st)
  val mutableEnvelopeWitness = st.get("bindingMutation") == ONE
  val mutablePolicyWitness = st.get("policyMutation") == ONE

  val anyDiscrepancy =
    outcomeWithoutAdmissionWitness
      or multipleAdmissionsWitness
      or proposalFilteringWitness
      or extraProposalMethodsWitness
      or uncontrolledTeardownWitness
      or nonconformingHitlWitness
      or mutableEnvelopeWitness
      or mutablePolicyWitness
}
