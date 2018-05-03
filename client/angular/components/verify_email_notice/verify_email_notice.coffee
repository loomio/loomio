AbilityService = require 'shared/services/ability_service.coffee'
AppConfig      = require 'shared/services/app_config.coffee'
Records        = require 'shared/services/records.coffee'

angular.module('loomioApp').directive 'verifyEmailNotice', ->
  scope: false
  restrict: 'E'
  templateUrl: 'generated/components/verify_email_notice/verify_email_notice.html'
  controller: ['$scope', ($scope) ->
    $scope.show = ->
      AbilityService.isNotEmailVerified() &&
      Records.stances.find(participantId: AppConfig.currentUserId).length > 0
  ]
