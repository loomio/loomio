angular.module('loomioApp').controller 'StartProposalCardController', ($scope, $translate, $modal, ProposalModel) ->
  $scope.openForm = ->
    modalInstance = $modal.open
      templateUrl: 'generated/templates/proposal_form.html'
      controller: 'ProposalFormController'
      resolve:
        proposal: ->
          new ProposalModel(discussion_id: $scope.discussion.id)


    modalInstance.result.then ->
      # something
