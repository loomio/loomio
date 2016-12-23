angular.module('loomioApp').directive 'decisionToolsCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/decision_tools_card/decision_tools_card.html'
  replace: true
  controller: ($scope, AppConfig, Records, ModalService, PollProposalForm) ->
    $scope.pollForms =
      proposal:   PollProposalForm
      # engagement: EngagementProposalForm
      # poll:       PollPollForm

    $scope.fieldFromTemplate = (pollType, field) ->
      AppConfig.pollTemplates[pollType][field]

    $scope.startPoll = (pollType) ->
      ModalService.open $scope.pollForms[pollType], poll: -> Records.polls.build
        pollType:              pollType
        discussionId:          $scope.discussion.id
        pollOptionsAttributes: $scope.fieldFromTemplate(pollType, 'poll_options_attributes')
