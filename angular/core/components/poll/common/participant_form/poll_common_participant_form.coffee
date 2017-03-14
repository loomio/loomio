angular.module('loomioApp').directive 'pollCommonParticipantForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/common/participant_form/poll_common_participant_form.html'
  controller: ($scope, AbilityService) ->
    $scope.isLoggedIn = ->
      AbilityService.isLoggedIn()
