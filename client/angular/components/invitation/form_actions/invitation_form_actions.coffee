Records      = require 'shared/services/records.coffee'
EventBus     = require 'shared/services/event_bus.coffee'
FlashService = require 'shared/services/flash_service.coffee'

{ submitForm } = require 'shared/helpers/form.coffee'

angular.module('loomioApp').directive 'invitationFormActions', ->
  scope: {invitationForm: '='}
  templateUrl: 'generated/components/invitation/form_actions/invitation_form_actions.html'
  controller: ['$scope', ($scope) ->
    $scope.submit = ->
      if $scope.invitationForm.hasInvitees()
        submitForm($scope, $scope.invitationForm,
          submitFn: Records.invitations.sendByEmail
          successCallback: (response) =>
            EventBus.emit $scope, 'nextStep'
            invitationCount = response.invitations.length
            switch invitationCount
              when 0 then $scope.noInvitations = true
              when 1 then FlashService.success 'invitation_form.messages.invitation_sent'
              else        FlashService.success 'invitation_form.messages.invitations_sent', count: invitationCount
        )()
      else
        EventBus.emit $scope, 'nextStep'


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
  ]
