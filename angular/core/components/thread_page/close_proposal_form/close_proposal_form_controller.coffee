angular.module('loomioApp').controller 'CloseProposalFormController', ($scope, $rootScope, FormService, proposal) ->

  $scope.proposal = proposal

  $scope.submit = FormService.submit $scope, $scope.proposal,
    submitFn: $scope.proposal.close
    flashSuccess: 'close_proposal_form.messages.success'
    successCallback: ->
      $rootScope.$broadcast 'setSelectedProposal'
