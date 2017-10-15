angular.module('loomioApp').directive 'invitationFormActions', ->
  scope: {group: '='}
  templateUrl: 'generated/components/invitation/form_actions/invitation_form_actions.html'
  controller: ($scope, Records, LoadingService, FormService) ->
    $scope.submit = ->
      if $scope.invitees().length == 0
        $scope.$emit 'inviteComplete'
      else
        submitForm()

    submitForm = FormService.submit $scope, $scope.form,
      drafts: true
      submitFn: Records.invitations.sendByEmail
      successCallback: (response) =>
        $scope.$emit 'inviteComplete'
        invitationCount = response.invitations.length
        switch invitationCount
          when 0 then $scope.noInvitations = true
          when 1 then FlashService.success 'invitation_form.messages.invitation_sent'
          else        FlashService.success 'invitation_form.messages.invitations_sent', count: invitationCount

    $scope.submitText = ->
      if $scope.form.emails.length > 0
        'common.action.send'
      else
        'invitation_form.done'
