angular.module('loomioApp').factory 'ExtendProposalForm', ->
  templateUrl: 'generated/components/thread_page/extend_proposal_form/extend_proposal_form.html'
  controller: ($scope, proposal, FlashService) ->
    $scope.proposal = proposal.clone()

    $scope.submit = ->
      $scope.proposal.save().then ->
        $scope.$close()
        FlashService.success 'extend_proposal_form.success'

    $scope.cancel = ($event) ->
      $scope.$close()
