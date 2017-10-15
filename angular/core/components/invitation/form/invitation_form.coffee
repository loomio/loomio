angular.module('loomioApp').directive 'invitationForm', ->
  scope: {group: '=', selectGroup: '='}
  templateUrl: 'generated/components/invitation/form/invitation_form.html'
  controller: ($scope, AppConfig, Records, Session, AbilityService, FormService, FlashService, RestfulClient, ModalService, AddMembersModal) ->

    $scope.availableGroups = ->
      _.filter Session.user().groups(), (g) ->
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

    $scope.invalidEmail = ->
      $scope.invitees().length == 0 and $scope.form.emails.length > 0

    $scope.canSubmit = ->
      $scope.invitees().length > 0 and $scope.form.group()

    $scope.copied = ->
      FlashService.success('common.copied')

    $scope.invitationLink = ->
      return unless $scope.form.group() and $scope.form.group().shareableInvitation()
      $scope.form.group().shareableInvitation().url

    return
