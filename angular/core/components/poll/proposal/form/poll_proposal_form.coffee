angular.module('loomioApp').factory 'PollProposalForm', ->
  templateUrl: 'generated/components/poll/proposal/form/poll_proposal_form.html'
  controller: ($scope, poll) ->
    $scope.poll = poll.clone()
