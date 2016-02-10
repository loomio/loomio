angular.module('loomioApp').factory 'InvitationForm', ->
  templateUrl: 'generated/components/invitation_form/invitation_form.html'
  controller: ($scope, group, Records, CurrentUser, AbilityService, FormService, FlashService, RestfulClient, ModalService, TeamLinkModal, AddMembersModal) ->

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

    $scope.getTeamLink = ->
      ModalService.open TeamLinkModal, group: -> $scope.form.group()

    $scope.canSubmit = ->
      $scope.invitees().length > 0 and $scope.form.group()

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
