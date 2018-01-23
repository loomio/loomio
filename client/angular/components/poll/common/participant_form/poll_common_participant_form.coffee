AbilityService = require 'shared/services/ability_service.coffee'

angular.module('loomioApp').directive 'pollCommonParticipantForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/common/participant_form/poll_common_participant_form.html'
  controller: ['$scope', ($scope) ->
    $scope.showParticipantForm = ->
      !AbilityService.isLoggedIn() && $scope.stance.isNew()
  ]
