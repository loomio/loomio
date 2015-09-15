angular.module('loomioApp').factory 'InvitationForm', ->
  templateUrl: 'generated/components/invitation_form/invitation_form.html'
  controller: ($scope, $rootScope, group, Records, CurrentUser, AbilityService, LoadingService, FlashService) ->
    $scope.group = group
    $scope.invitations = []
    $scope.messageFieldHidden = true

    $scope.showMessageField = ->
      $scope.messageFieldHidden = false

    $scope.hasInvitations = ->
      $scope.invitations.length > 0

    $scope.invitationsCount = (types...) ->
      _.reduce $scope.invitations, ((total, invitation) ->
        if _.isEmpty(types) or _.contains(types, invitation.type)
          total + (invitation.count or 1)
        else
          total
      ), 0

    $scope.fragmentIsValidEmail = ->
      $scope.emailValidation.$valid

    $scope.invitableEmail = ->
      type: 'email'
      name: "<#{$scope.fragment}>"
      email: $scope.fragment

    $scope.invitableGroups = ->
      groups = _.filter $scope.availableGroups(), (group) ->
        group.id != $scope.group.id and
        matchesFragment(group.name) and
        !existsAlready('group', 'id', group.id)

      _.map groups, (group) ->
        id:       group.id
        type:     'group'
        name:     group.name
        subtitle: "Add all #{group.membershipsCount} members"
        image:    group.logoUrl()
        count:    group.membershipsCount

    $scope.invitableUsers = ->
      memberIds = _.uniq _.flatten _.map $scope.availableGroups(), (group) -> group.memberIds()
      memberIds = _.filter memberIds, (memberId) ->
        !_.contains $scope.group.memberIds(), memberId
      users = _.filter Records.users.find(memberIds), (user) ->
        !user.membershipFor($scope.group) and
        matchesFragment(user.searchFragment, user.name, user.username) and
        !existsAlready('user', 'id', user.id)

      _.map users, (user) ->
        id:       user.id
        type:     'user'
        name:     user.name
        subtitle: "@#{user.username}"
        image:    user.avatarUrl

    $scope.invitableContacts = ->
      contacts = _.filter CurrentUser.contacts(), (contact) ->
        matchesFragment(contact.name, contact.email) and
        !existsAlready('contact', 'email', contact.email)

      _.map contacts, (contact) ->
        type:     'contact'
        name:     contact.name
        email:    contact.email
        subtitle: "<#{contact.email}>"
        image:    contact.avatarUrl

    matchesFragment = (fields...) ->
      _.some _.map fields, (field) ->
        return false unless field?
        ~field.search new RegExp($scope.fragment, 'i')

    existsAlready = (type, uniqueField, value) ->
      _.some _.map $scope.invitations, (invitation) ->
        invitation.type == type and invitation[uniqueField] = value

    $scope.getInvitables = ->
      return if $scope.fragment == ''
      $scope.getInvitablesExecuting = true
      Promise.all([
        Records.contacts.fetchInvitables($scope.fragment, $scope.group.key),
        Records.memberships.fetchInvitables($scope.fragment, $scope.group.key)
      ]).then ->
        $scope.getInvitablesExecuting = false
        $scope.invitables()

    $scope.invitables = ->
      _.take _.union($scope.invitableUsers(),
                     $scope.invitableContacts(),
                     $scope.invitableGroups(),
                     _.compact([$scope.invitableEmail() if $scope.fragmentIsValidEmail()])), 5

    $scope.availableGroups = ->
      _.filter CurrentUser.groups(), (group) ->
        AbilityService.canAddMembers(group)

    $scope.addInvitation = (invitation) ->
      $scope.fragment = ''
      $scope.invitations.push invitation

    $scope.submit = ->
      $scope.isDisabled = true
      Records.invitations.remote.create(invitationsParams()).then ->
        FlashService.success $scope.successMessage(), members: $scope.memberCount(), emails: $scope.emailCount()
        $scope.$close()
        Records.memberships.fetchByGroup $scope.group.key, per: 25
      , ->
        $scope.isDisabled = false
        $rootScope.$broadcast 'pageError', 'cantCreateInvitations'

    $scope.successMessage = ->
      if $scope.memberCount() > 0 and $scope.emailCount() > 0
        'invitation.messages.members_added_and_emails_sent'
      else if $scope.memberCount() > 0
        'invitation.messages.members_added'
      else if $scope.emailCount() > 0
        'invitation.messages.emails_sent'
      else
        'invitation.messages.no_invitations'

    $scope.memberCount = ->
      $scope.invitationsCount('user', 'group')

    $scope.emailCount = ->
      $scope.invitationsCount('contact', 'email')

    invitationsParams = ->
      invitations: $scope.invitations
      group_key: $scope.group.key
      message: $scope.message

    return
