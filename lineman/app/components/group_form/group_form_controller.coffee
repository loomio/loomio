angular.module('loomioApp').controller 'GroupFormController', ($routeParams, $rootScope, $location, Records, FormService) ->

  if $routeParams.key
    Records.groups.findOrFetchByKey($routeParams.key).then (group) =>
      @group = group
      FormService.applyForm @, @group
  else if $routeParams.parentId
    Records.groups.findOrFetchByKey($routeParams.parentId).then (parent) =>
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

  @onSuccess = (newGroup) ->
    $location.path "/g/#{newGroup.key}"

  return
