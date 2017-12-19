angular.module('loomioApp').directive 'pollCommonStartForm', (AppConfig, Records, ModalService, PollCommonStartModal, PollService) ->
  scope: {discussion: '=?', group: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/start_form/poll_common_start_form.html'
  replace: true
  controller: ($scope) ->
    $scope.discussion = $scope.discussion or {}
    $scope.group      = $scope.group or {}

    $scope.pollTypes = -> AppConfig.pollTypes

    $scope.startPoll = (pollType) ->
      ModalService.open PollCommonStartModal, poll: ->
        Records.polls.build
          pollType:              pollType
          discussionId:          $scope.discussion.id
          groupId:               $scope.discussion.groupId or $scope.group.id
          pollOptionNames:       _.pluck $scope.fieldFromTemplate(pollType, 'poll_options_attributes'), 'name'

    $scope.fieldFromTemplate = (pollType, field) ->
      PollService.fieldFromTemplate(pollType, field)
