angular.module('loomioApp').directive 'pollCommonParticipantForm', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/common/participant_form/poll_common_participant_form.html'
  controller: ($scope, $location, AbilityService) ->
    $scope.showParticipantForm = ->
      !AbilityService.isLoggedIn() && $scope.stance.isNew()
