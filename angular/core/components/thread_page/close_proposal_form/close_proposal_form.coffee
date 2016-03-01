angular.module('loomioApp').factory 'CloseProposalForm', ->
  templateUrl: 'generated/components/thread_page/close_proposal_form/close_proposal_form.html'
  controller: ($scope, $rootScope, FormService, proposal) ->
    $scope.proposal = proposal

    $scope.submit = FormService.submit $scope, $scope.proposal,
      submitFn: $scope.proposal.close
      flashSuccess: 'close_proposal_form.messages.success'
      successCallback: ->
        $rootScope.$broadcast 'setSelectedProposal'
