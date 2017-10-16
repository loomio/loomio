angular.module('loomioApp').directive 'invitationFormActions', ->
  scope: {invitationForm: '='}
  templateUrl: 'generated/components/invitation/form_actions/invitation_form_actions.html'
  controller: ($scope, Records, LoadingService, FormService, FlashService) ->
    $scope.submit = ->
      if $scope.invitationForm.hasInvitees()
        submitForm()
      else
        $scope.$emit 'inviteComplete'

    submitForm = FormService.submit $scope, $scope.invitationForm,
      submitFn: Records.invitations.sendByEmail
      successCallback: (response) =>
        $scope.$emit 'inviteComplete'
        invitationCount = response.invitations.length
        switch invitationCount
          when 0 then $scope.noInvitations = true
          when 1 then FlashService.success 'invitation_form.messages.invitation_sent'
          else        FlashService.success 'invitation_form.messages.invitations_sent', count: invitationCount

    $scope.submitText = ->
      if $scope.invitationForm.hasEmails()
        'common.action.send'
      else
        'invitation_form.done'

    $scope.canSubmit = ->
      return true unless $scope.invitationForm.hasEmails()
      !$scope.isDisabled and
      $scope.invitationForm.invitees().length > 0 and
      $scope.invitationForm.invitees().length < 100
