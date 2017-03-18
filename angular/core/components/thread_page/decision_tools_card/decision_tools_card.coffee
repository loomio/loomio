angular.module('loomioApp').directive 'decisionToolsCard', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/decision_tools_card/decision_tools_card.html'
  replace: true
  controller: ($scope, AppConfig, Records, ModalService, PollCommonFormModal, PollService) ->

    $scope.pollTypes = ->
      _.keys PollService.activePollTemplates()

    $scope.startPoll = (pollType) ->
      ModalService.open PollCommonFormModal, poll: ->
        Records.polls.build
          pollType:              pollType
          discussionId:          $scope.discussion.id
          pollOptionNames:       _.pluck $scope.fieldFromTemplate(pollType, 'poll_options_attributes'), 'name'

    $scope.fieldFromTemplate = (pollType, field) ->
      PollService.fieldFromTemplate(pollType, field)
