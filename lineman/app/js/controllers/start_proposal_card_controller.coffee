angular.module('loomioApp').controller 'StartProposalCardController', ($scope, $translate, $modal, Records) ->
  $scope.openForm = ->
    modalInstance = $modal.open
      templateUrl: 'generated/templates/proposal_form.html'
      controller: 'ProposalFormController'
      resolve:
        proposal: ->
          Records.proposals.new(discussion_id: $scope.discussion.id)


    modalInstance.result.then ->
      # something
