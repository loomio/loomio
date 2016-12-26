angular.module('loomioApp').directive 'decisionToolsCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/decision_tools_card/decision_tools_card.html'
  replace: true
  controller: ($scope, AppConfig, Records, ModalService, PollService) ->

    $scope.pollTypes = ->
      _.keys PollService.activePollTemplates()

    $scope.startPoll = (pollType) ->
      ModalService.open PollService.formFor(pollType), poll: -> Records.polls.build
        pollType:              pollType
        discussionId:          $scope.discussion.id
        pollOptionsAttributes: $scope.fieldFromTemplate(pollType, 'poll_options_attributes')

    $scope.fieldFromTemplate = (pollType, field) ->
      PollService.fieldFromTemplate(pollType, field)
