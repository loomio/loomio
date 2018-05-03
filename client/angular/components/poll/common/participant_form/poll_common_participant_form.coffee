AbilityService = require 'shared/services/ability_service.coffee'
Session        = require 'shared/services/session.coffee'

angular.module('loomioApp').directive 'pollCommonParticipantForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/common/participant_form/poll_common_participant_form.html'
  controller: ['$scope', ($scope) ->
    $scope.showParticipantForm = ->
      Session.user() && !Session.user().emailVerified && $scope.stance.isNew()
      
    if $scope.showParticipantForm()
      $scope.stance.visitorAttributes.name = Session.user().name
      $scope.stance.visitorAttributes.email = Session.user().email
  ]
