angular.module('loomioApp').factory 'ProposalFormService', ($uibModal, Records) ->
  new class ProposalFormService
    openCloseProposalModal: (proposal) ->
      $uibModal.open
        templateUrl: 'generated/components/thread_page/close_proposal_form/close_proposal_form.html',
        controller: 'CloseProposalFormController',
        resolve:
          proposal: -> Records.proposals.find(proposal.id)

    openExtendProposalModal: (proposal) ->
      $uibModal.open
        templateUrl: 'generated/components/thread_page/extend_proposal_form/extend_proposal_form.html',
        controller: 'ExtendProposalFormController',
        resolve:
          proposal: -> Records.proposals.find(proposal.id)

    openSetOutcomeModal: (proposal) ->
      modalInstance = $uibModal.open
        templateUrl: 'generated/components/thread_page/proposal_outcome_form/proposal_outcome_form.html'
        controller: 'ProposalOutcomeFormController'
        resolve:
          proposal: -> proposal

