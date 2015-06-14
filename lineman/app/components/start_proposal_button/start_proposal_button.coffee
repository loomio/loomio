angular.module('loomioApp').directive 'startProposalButton', ->
  scope: { discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_lintel/thread_lintel.html'
  replace: true
  controller: ($scope, Records, ModalService, ProposalForm, CurrentUser) ->

    $scope.canStartProposal = ->
      $scope.discussion.hasActiveProposal() and CurrentUser.canStartProposals($scope.discussion)

    $scope.startProposal = ->
      ModalService.open ProposalForm, proposal: -> Records.proposals.initialize(discussion_id: $scope.discussion.id)
