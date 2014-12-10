angular.module('loomioApp').factory 'ProposalFormService', ($modal, Records) ->
  new class ProposalFormService
    openEditProposalModal: (proposal) ->
      $modal.open
        templateUrl: 'generated/modules/discussion_page/proposals_card/proposal_form/proposal_form.html',
        controller: 'ProposalFormController',
        resolve:
          proposal: -> proposal

    openStartProposalModal: (discussion) ->
      modalInstance = $modal.open
        templateUrl: 'generated/modules/discussion_page/proposals_card/proposal_form/proposal_form.html'
        controller: 'ProposalFormController'
        resolve:
          proposal: ->
            Records.proposals.initialize(discussion_id: discussion.id)

    showCloseProposalModal: (proposal) ->
      $modal.open
        templateUrl: 'generated/modules/discussion_page/proposals_card/close_proposal_form/close_proposal_form.html',
        controller: 'CloseProposalFormController',
        resolve:
          proposal: -> proposal
