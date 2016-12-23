angular.module('loomioApp').directive 'decisionToolsCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/decision_tools_card/decision_tools_card.html'
  replace: true
  controller: ($scope, AppConfig, Records, ModalService, PollProposalForm) ->
    $scope.pollTypes =
      [
        {name: "proposal",   icon: "thumbs_up_down"},
        {name: "engagement", icon: "check_circle"},
        {name: "poll",       icon: "equalizer"}
      ]

    $scope.startPoll = (pollType) ->
      ModalService.open PollProposalForm, poll: -> Records.polls.build
        pollType:              pollType
        discussionId:          $scope.discussion.id
        pollOptionsAttributes: AppConfig.pollTemplates[pollType].poll_options_attributes
