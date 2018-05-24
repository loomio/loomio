AppConfig      = require 'shared/services/app_config'
AbilityService = require 'shared/services/ability_service'
Session        = require 'shared/services/session'

angular.module('loomioApp').directive 'pollCommonParticipantForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/common/participant_form/poll_common_participant_form.html'
  controller: ['$scope', ($scope) ->
    $scope.termsUrl     = AppConfig.theme.terms_url
    $scope.privacyUrl   = AppConfig.theme.privacy_url

    $scope.showParticipantForm = ->
      Session.user() && !Session.user().emailVerified && $scope.stance.isNew()

    if $scope.showParticipantForm()
      $scope.stance.visitorAttributes.name = Session.user().name
      $scope.stance.visitorAttributes.email = Session.user().email
  ]
