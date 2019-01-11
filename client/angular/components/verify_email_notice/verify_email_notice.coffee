AbilityService = require 'shared/services/ability_service'
AppConfig      = require 'shared/services/app_config'
Records        = require 'shared/services/records'

angular.module('loomioApp').directive 'verifyEmailNotice', ->
  scope: false
  restrict: 'E'
  template: require('./verify_email_notice.haml')
  controller: ['$scope', ($scope) ->
    $scope.show = ->
      AbilityService.isNotEmailVerified() &&
      Records.stances.find(participantId: AppConfig.currentUserId).length > 0
  ]
