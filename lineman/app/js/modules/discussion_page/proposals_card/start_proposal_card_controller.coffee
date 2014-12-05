angular.module('loomioApp').controller 'StartProposalCardController', ($scope, $translate, $modal, Records) ->
  $scope.openForm = ->
    modalInstance = $modal.open
      templateUrl: 'generated/js/modules/discussion_page/proposals_card/proposal_form.html'
      controller: 'ProposalFormController'
      resolve:
        proposal: ->
          Records.proposals.initialize(discussion_id: $scope.discussion.id)

    modalInstance.result.then ->
      # something
