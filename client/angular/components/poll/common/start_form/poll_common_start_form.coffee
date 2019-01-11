AppConfig    = require 'shared/services/app_config'
Records      = require 'shared/services/records'
ModalService = require 'shared/services/modal_service'

{ fieldFromTemplate } = require 'shared/helpers/poll'

angular.module('loomioApp').directive 'pollCommonStartForm', ->
  scope: {discussion: '=?', group: '=?'}
  restrict: 'E'
  template: require('./poll_common_start_form.haml')
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.discussion = $scope.discussion or {}
    $scope.group      = $scope.group or {}

    $scope.pollTypes = -> AppConfig.pollTypes

    $scope.startPoll = (pollType) ->
      ModalService.open 'PollCommonStartModal', poll: ->
        Records.polls.build
          pollType:              pollType
          discussionId:          $scope.discussion.id
          groupId:               $scope.discussion.groupId or $scope.group.id
          pollOptionNames:       _.map $scope.fieldFromTemplate(pollType, 'poll_options_attributes'), 'name'

    $scope.fieldFromTemplate = (pollType, field) ->
      fieldFromTemplate(pollType, field)
  ]
