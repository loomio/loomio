angular.module('loomioApp').factory 'InvitationForm', ->
  templateUrl: 'generated/components/invitation_form/invitation_form.html'
  controller: ($scope, group, Records, CurrentUser, AbilityService, FlashService, RestfulClient, ModalService, TeamLinkModal, AddMembersModal) ->

    $scope.addMembers = ->
      ModalService.open AddMembersModal, group: -> $scope.group

    $scope.addCustomMessage = ->
      $scope.showCustomMessageField = true

    $scope.availableGroups = ->
      _.filter $scope.userGroups(), (group) ->
        AbilityService.canAddMembers(group)

    $scope.userGroups = ->
      CurrentUser.groups()

    $scope.maxInvitations = ->
      $scope.form.emailAddresses.split(' ').length > 100

    $scope.getTeamLink = ->
      ModalService.open TeamLinkModal, group: -> $scope.group

    $scope.submit = ->
      $scope.isDisabled = true
      Records.invitations.sendByEmail
        groupId: $scope.group.id
        emailAddresses: $scope.form.emailAddresses
        message: $scope.form.message
      .then (data) ->
        invitationCount = data.invitations.length
        switch invitationCount
          when 0
            $scope.noInvitations = true
          when 1
            FlashService.success 'invitation_form.messages.invitation_sent'
            $scope.$close()
          else
            FlashService.success 'invitation_form.messages.invitations_sent', count: invitationCount
            $scope.$close()
      .finally ->
        $scope.isDisabled = false

    $scope.group = group
    $scope.form = { emailAddresses: '' }
    $scope.showCustomMessageField = false
    $scope.isDisabled = false
    $scope.noInvitations = false

    if !(group?)
      $scope.group = $scope.userGroups()[0]

    return
