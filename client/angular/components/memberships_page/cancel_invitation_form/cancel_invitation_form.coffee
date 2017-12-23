Records = require 'shared/services/records.coffee'

angular.module('loomioApp').factory 'CancelInvitationForm', (FlashService, FormService) ->
  templateUrl: 'generated/components/memberships_page/cancel_invitation_form/cancel_invitation_form.html'
  controller: ($scope, invitation) ->
    $scope.invitation = invitation

    $scope.submit = FormService.submit $scope, $scope.invitation,
      submitFn: $scope.invitation.destroy
      flashSuccess: 'cancel_invitation_form.messages.success'
