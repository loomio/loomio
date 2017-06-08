angular.module('loomioApp').directive 'pollProposalForm', ->
  scope: {poll: '=', back: '=?'}
  templateUrl: 'generated/components/poll/proposal/form/poll_proposal_form.html'
  controller: ($scope, PollService, AttachmentService, KeyEventService, MentionService) ->
    $scope.submit = PollService.submitPoll $scope, $scope.poll,
      prepareFn: ->
        $scope.$emit 'processing'
        $scope.poll.pollOptionNames = _.pluck PollService.fieldFromTemplate('proposal', 'poll_options_attributes'), 'name'

    MentionService.applyMentions($scope, $scope.poll)
    KeyEventService.submitOnEnter($scope)
