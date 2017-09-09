angular.module('loomioApp').directive 'invitationForm', ->
  scope: {group: '=', selectGroup: '='}
  templateUrl: 'generated/components/invitation/form/invitation_form.html'
  controller: ($scope, AppConfig, Records, Session, AbilityService, FormService, FlashService, RestfulClient, ModalService, AddMembersModal) ->

    $scope.availableGroups = ->
      _.filter Session.user().formalGroups(), (g) ->
        AbilityService.canAddMembers(g)

    $scope.form = Records.invitationForms.build(groupId: $scope.group.id)
    $scope.fetchShareableInvitation = ->
      Records.invitations.fetchShareableInvitationByGroupId($scope.form.group().id) if $scope.form.group()
    $scope.fetchShareableInvitation()
    $scope.showCustomMessageField = false
    $scope.isDisabled = false
    $scope.noInvitations = false

    $scope.addMembers = ->
      ModalService.open AddMembersModal, group: -> $scope.form.group()

    $scope.showCustomMessageField = ->
      $scope.addCustomMessageClicked or $scope.form.message

    $scope.addCustomMessage = ->
      $scope.addCustomMessageClicked = true

    $scope.invitees = ->
      # something@something.something where something does not include ; or , or < or >
      $scope.form.emails.match(/[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/g) or []

    $scope.maxInvitations = ->
      $scope.invitees().length > 100

    $scope.submitText = ->
      if $scope.form.emails.length > 0
        'common.action.send'
      else
        'invitation_form.done'

    $scope.invalidEmail = ->
      $scope.invitees().length == 0 and $scope.form.emails.length > 0

    $scope.canSubmit = ->
      $scope.invitees().length > 0 and $scope.form.group()

    $scope.copied = ->
      FlashService.success('common.copied')

    $scope.invitationLink = ->
      return unless $scope.form.group() and $scope.form.group().shareableInvitation()
      $scope.form.group().shareableInvitation().url

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

    return
