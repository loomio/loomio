angular.module('loomioApp').factory 'InvitationForm', ->
  templateUrl: 'generated/components/invitation_form/invitation_form.html'
  controller: ($scope, group, Records, CurrentUser, AbilityService, FormService, FlashService, RestfulClient, ModalService, AddMembersModal, AppConfig) ->

    Records.invitations.fetchShareableInvitationByGroupId(group.id)

    $scope.availableGroups = ->
      _.filter CurrentUser.groups(), (group) ->
        AbilityService.canAddMembers(group)

    $scope.form = Records.invitationForms.build(groupId: group.id or (_.first($scope.availableGroups()) or {}).id)
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
      _.compact $scope.form.emails.split(' ')

    $scope.maxInvitations = ->
      $scope.invitees().length > 100

    $scope.submitText = ->
      if $scope.invitees().length > 0
        'invitation_form.send'
      else
        'invitation_form.done'

    $scope.canSubmit = ->
      $scope.invitees().length > 0 and $scope.form.group()

    $scope.invitation = ->
      group.shareableInvitation()

    $scope.copied = ->
      FlashService.success('common.copied')

    $scope.invitationLink = ->
      return unless group.shareableInvitation()
      [AppConfig.baseUrl, 'invitations/', group.shareableInvitation().token].join('')

    $scope.submit = FormService.submit $scope, $scope.form,
      allowDrafts: true
      submitFn: Records.invitations.sendByEmail
      successCallback: (response) =>
        invitationCount = response.invitations.length
        switch invitationCount
          when 0 then $scope.noInvitations = true
          when 1 then FlashService.success 'invitation_form.messages.invitation_sent'
          else        FlashService.success 'invitation_form.messages.invitations_sent', count: invitationCount

    return
