AppConfig = require 'shared/services/app_config'
Session   = require 'shared/services/session'
Records   = require 'shared/services/records'

angular.module('loomioApp').directive 'pollCommonToolTip', ->
  scope: {poll: '='}
  template: require('./poll_common_tool_tip.haml')
  controller: ['$scope', ($scope) ->
    $scope.showHelpLink = AppConfig.features.app.help_link
    experienceKey = $scope.poll.pollType+"_tool_tip"
    $scope.collapsed = Session.user().hasExperienced(experienceKey)

    if !Session.user().hasExperienced(experienceKey)
      Records.users.saveExperience(experienceKey)

    $scope.hide = ->
      $scope.collapsed = true

    $scope.show = ->
      $scope.collapsed = false
  ]
