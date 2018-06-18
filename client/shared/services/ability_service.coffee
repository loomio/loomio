AppConfig     = require 'shared/services/app_config'
Records       = require 'shared/services/records'
Session       = require 'shared/services/session'
LmoUrlService = require 'shared/services/lmo_url_service'

module.exports = new class AbilityService

  isNotEmailVerified: ->
    @isLoggedIn() and !Session.user().emailVerified

  isLoggedIn: ->
    @isUser() and !Session.user().restricted?

  isSiteAdmin: ->
    @isLoggedIn() and Session.user().isAdmin

  isEmailVerified: ->
    @isLoggedIn() && Session.user().emailVerified

  isUser: ->
    AppConfig.currentUserId?

  canContactUser: (user) ->
    @isLoggedIn() &&
    Session.user().id != user.id &&
    _.intersection(Session.user().groupIds(), user.groupIds()).length

  canAddComment: (thread) ->
    _.contains thread.members(), Session.user()

  canRespondToComment: (comment) ->
    _.contains comment.discussion().members(), Session.user()

  canForkComment: (comment) ->
    @canMoveThread(comment.discussion()) &&
    !comment.isReply()

  canStartPoll: (model) ->
    return unless model
    switch model.constructor.singular
      when 'discussion' then @canStartPoll(model.group()) || @canStartPoll(model.guestGroup())
      when 'group'      then (@canAdministerGroup(model) or Session.user().isMemberOf(model) and model.membersCanRaiseMotions)

  canParticipateInPoll: (poll) ->
    return false unless poll
    return false unless poll.isActive()
    poll.anyoneCanParticipate or
    @adminOf(poll) or
    (@memberOf(poll) and (!poll.group() or poll.group().membersCanVote))

  memberOf: (model) ->
    _.any _.compact(model.groups()), (group) -> Session.user().isMemberOf(group)

  adminOf: (model) ->
    _.any _.compact(model.groups()), (group) -> Session.user().isAdminOf(group)

  canReactToPoll: (poll) ->
    @isEmailVerified() and @canParticipateInPoll(poll)

  canEditStance: (stance) ->
    Session.user() == stance.author()

  canEditThread: (thread) ->
    @canAdministerGroup(thread.group()) or
    Session.user().isMemberOf(thread.group()) and
    (Session.user().isAuthorOf(thread) or thread.group().membersCanEditDiscussions)

  canRemoveEventFromThread: (event) ->
    event.kind == 'discussion_edited' && @canAdministerDiscussion(event.discussion())

  canCloseThread: (thread) ->
    @canAdministerDiscussion(thread)

  canReopenThread: (thread) ->
    @canAdministerDiscussion(thread)

  canPinThread: (thread) ->
    !thread.closedAt && !thread.pinned && @canAdministerGroup(thread.group())

  canUnpinThread: (thread) ->
    !thread.closedAt && thread.pinned && @canAdministerGroup(thread.group())

  canMoveThread: (thread) ->
    @canAdministerGroup(thread.group()) or
    Session.user().isAuthorOf(thread)

  canDeleteThread: (thread) ->
    @canAdministerGroup(thread.group()) or
    Session.user().isAuthorOf(thread)

  canChangeGroupVolume: (group) ->
    Session.user().isMemberOf(group)

  canAdminister: (model) ->
    switch model.constructor.singular
      when 'group'                     then @canAdministerGroup(model.group())
      when 'discussion', 'comment'     then @canAdministerDiscussion(model.discussion())
      when 'outcome', 'stance', 'poll' then @canAdministerPoll(model.poll())

  canAdministerGroup: (group) ->
    Session.user().isAdminOf(group)

  canAdministerDiscussion: (discussion) ->
    Session.user().isAuthorOf(discussion) or
    @canAdministerGroup(discussion.group())

  canChangeVolume: (discussion) ->
    _.contains discussion.members(), Session.user()

  canManageGroupSubscription: (group) ->
    group.isParent() and
    @canAdministerGroup(group) and
    group.subscriptionKind? and
    group.subscriptionKind != 'trial' and
    group.subscriptionPaymentMethod != 'manual'

  isCreatorOf: (group) ->
    Session.user().id == group.creatorId

  canStartThread: (group) ->
    @canAdministerGroup(group) or
    (Session.user().isMemberOf(group) and group.membersCanStartDiscussions)

  canAddMembersToGroup: (group) ->
    @canAdministerGroup(group) or
    (Session.user().isMemberOf(group) and group.membersCanAddMembers)

  canAddMembers: (group) ->
    @canAddMembersToGroup(group) || @canAddMembersToGroup(group.targetModel().group())

  canAddDocuments: (group) ->
    @canAdministerGroup(group)

  canEditDocument: (group) ->
    @canAdministerGroup(group)

  canCreateSubgroups: (group) ->
    group.isParent() and
    (@canAdministerGroup(group) or
    (Session.user().isMemberOf(group) and group.membersCanCreateSubgroups))

  canEditGroup: (group) ->
    @canAdministerGroup(group) or @isSiteAdmin()

  canLeaveGroup: (group) ->
    Session.user().membershipFor(group)?

  canArchiveGroup: (group) ->
    @canAdministerGroup(group)

  canEditComment: (comment) ->
    Session.user().isMemberOf(comment.group()) and
    Session.user().isAuthorOf(comment) and
    (comment.isMostRecent() or comment.group().membersCanEditComments)

  canDeleteComment: (comment) ->
    (Session.user().isMemberOf(comment.group()) and
    Session.user().isAuthorOf(comment)) or
    @canAdministerGroup(comment.group())

  canRemoveMembership: (membership) ->
    membership and
    (membership.user() == Session.user() or @canAdministerGroup(membership.group()))

  canSetMembershipTitle: (membership) ->
    Session.user() == membership.user() or
    @canAdministerGroup(membership.group())

  canResendMembership: (membership) ->
    membership and
    !membership.acceptedAt and
    membership.inviter() == Session.user()

  canManageMembershipRequests: (group) ->
    (group.membersCanAddMembers and Session.user().isMemberOf(group)) or @canAdministerGroup(group)

  canViewPublicGroups: ->
    AppConfig.features.app.public_groups

  canStartGroups: ->
    @isEmailVerified() and (AppConfig.features.app.create_group || Session.user().isAdmin)

  canViewGroup: (group) ->
    !group.privacyIsSecret() or
    Session.user().isMemberOf(group)

  canViewPrivateContent: (group) ->
    Session.user().isMemberOf(group)

  canCreateContentFor: (group) ->
    Session.user().isMemberOf(group)

  canViewMemberships: (group) ->
    Session.user().isMemberOf(group)                       ||
    Session.user().isMemberOf(group.targetModel().group()) ||
    group.targetModel().anyoneCanParticipate

  canViewPendingMemberships: (group) ->
    @canAdministerGroup(group) || @canAdministerGroup(group.targetModel().group())

  canViewPreviousPolls: (group) ->
    @canViewGroup(group)

  canJoinGroup: (group) ->
    (group.membershipGrantedUpon == 'request') and
    @canViewGroup(group) and
    !Session.user().isMemberOf(group)

  canRequestMembership: (group) ->
    (group.membershipGrantedUpon == 'approval') and
    @canViewGroup(group) and
    !Session.user().isMemberOf(group)

  canTranslate: (model) ->
    AppConfig.inlineTranslation.isAvailable? and
    _.contains(AppConfig.inlineTranslation.supportedLangs, Session.user().locale) and
    !model.translation and
    Session.user().locale != model.author().locale

  canSubscribeToPoll: (poll) ->
    if poll.group()
      @canViewGroup(poll.group())
    else
      @canAdministerPoll() || _.contains(@poll().voters(), Session.user())

  canRemovePollOptions: (poll) ->
    poll.isNew() || (poll.isActive() && poll.stancesCount == 0)

  canEditPoll: (poll) ->
    poll.isActive() and @canAdministerPoll(poll)

  canDeletePoll: (poll) ->
    @canAdministerPoll(poll)

  canExportPoll: (poll) ->
    @canAdministerPoll(poll)

  canSetPollOutcome: (poll) ->
    poll.isClosed() and @canAdministerPoll(poll)

  canAdministerPoll: (poll) ->
    _.contains(poll.adminMembers(), Session.user()) || Session.user().isAuthorOf(poll)

  canClosePoll: (poll) ->
    @canEditPoll(poll)

  canReopenPoll: (poll) ->
    poll.isClosed() and @canAdministerPoll(poll)
