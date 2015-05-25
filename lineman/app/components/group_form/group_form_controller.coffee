angular.module('loomioApp').controller 'GroupFormController', ($routeParams, $rootScope, $location, Records, FormService) ->
  $rootScope.$broadcast('currentComponent', { page: 'groupFormPage'})

  if $routeParams.key
    Records.groups.findOrFetchByKey($routeParams.key).then (group) =>
      @group = group
      FormService.applyForm @, @group
  else if $routeParams.parentKey
    Records.groups.findOrFetchByKey($routeParams.parentKey).then (parent) =>
      @group = Records.groups.initialize
        parentId:                   parent.id
        visibleTo:                  parent.visibleTo
        membershipGrantedUpon:      parent.membershipGrantedUpon
        discussionPrivacyOptions:   parent.discussionPrivacyOptions
        membersCanAddMembers:       parent.membersCanAddMembers
        membersCanStartSubgroups:   parent.membersCanStartSubgroups
        membersCanStartDiscussions: parent.membersCanStartDiscussions
        membersCanEditDiscussions:  parent.membersCanEditDiscussions
        membersCanEditComments:     parent.membersCanEditComments
        membersCanRaiseMotions:     parent.membersCanRaiseMotions
        membersCanVote:             parent.membersCanVote
      FormService.applyForm @, @group
  else
    @group = Records.groups.initialize
      visibleTo: 'public',
      membershipGrantedUpon: 'request',
      discussionPrivacyOptions: 'public_only'
    FormService.applyForm @, @group

  @validVisibilityOption = (value) =>
    switch value
      when 'public'         then !@group.parentIsHidden()
      when 'parent_members' then @group.parentId
      when 'members'        then true

  @validMembershipOption = (value) =>
    switch value
      when 'request'    then @group.visibleTo != 'members'
      when 'approval'   then @group.visibleTo != 'members'
      when 'invitation' then true

  @validDiscussionOption = (value) =>
    switch value
      when 'public_only'       then @group.visibleTo != 'members'
      when 'public_or_private' then @group.visibleTo != 'members'
      when 'private_only'      then true

  @firstOption = (isVisible, options) =>
    =>
      for option in options
        return option if isVisible(option)
      return

  @firstVisibilityOption = @firstOption(@validVisibilityOption, ['public', 'parent_members', 'members'])
  @firstMembershipOption = @firstOption(@validMembershipOption, ['request', 'approval', 'invitation'])
  @firstDiscussionOption = @firstOption(@validDiscussionOption, ['public_only', 'public_or_private', 'private_only'])

  @updateOptions = =>
    if !@validVisibilityOption(@group.visibleTo)
      @group.visibleTo = @firstVisibilityOption()
    if !@validMembershipOption(@group.membershipGrantedUpon)
      @group.membershipGrantedUpon = @firstMembershipOption()
    if !@validDiscussionOption(@group.discussionPrivacyOptions)
      @group.discussionPrivacyOptions = @firstDiscussionOption(@group.discussionPrivacyOptions)

  @privacyTranslation = (value) =>
    if @group.parentId then "#{value}_subgroup" else value

  @onSuccess = (newGroup) ->
    $location.path "/g/#{newGroup.key}"

  return
