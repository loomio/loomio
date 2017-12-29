Records = require 'shared/services/records.coffee'

{ submitForm } = require 'angular/helpers/form.coffee'

angular.module('loomioApp').factory 'CancelInvitationForm', ->
  templateUrl: 'generated/components/memberships_page/cancel_invitation_form/cancel_invitation_form.html'
  controller: ['$scope', 'invitation', ($scope, invitation) ->
    $scope.invitation = invitation

    $scope.submit = submitForm $scope, $scope.invitation,
      submitFn: $scope.invitation.destroy
      flashSuccess: 'cancel_invitation_form.messages.success'
  ]
