angular.module('loomioApp').controller 'StartProposalCardController', ($scope, ProposalFormService) ->
  $scope.openForm = ->
    ProposalFormService.openStartProposalModal($scope.discussion)
