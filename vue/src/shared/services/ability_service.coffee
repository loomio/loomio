import AppConfig     from '@/shared/services/app_config'
import Records       from '@/shared/services/records'
import Session       from '@/shared/services/session'
import LmoUrlService from '@/shared/services/lmo_url_service'

export default new class AbilityService
  isNotEmailVerified: ->
    Session.isSignedIn() and !Session.user().emailVerified

  isSiteAdmin: ->
    Session.isSignedIn() and Session.user().isAdmin

  isEmailVerified: ->
    Session.isSignedIn() && Session.user().emailVerified

  isUser: ->
    AppConfig.currentUserId?

  canContactUser: (user) ->
    Session.isSignedIn() &&
    Session.user().id != user.id &&
    _.intersection(Session.user().groupIds(), user.groupIds()).length

  canAddComment: (thread) ->
    thread.membersInclude(Session.user())

  canRespondToComment: (comment) ->
    comment.discussion().membersInclude(Session.user())

  canStartPoll: (model) ->
    return unless model
    switch model.constructor.singular
      when 'discussion' then @canStartPoll(model.group())
      when 'group'      then model.adminsInclude(Session.user()) or (model.membersInclude(Session.user()) and model.membersCanRaiseMotions)

  canParticipateInPoll: (poll) ->
    return false unless poll
    return false unless poll.isActive()
    poll.anyoneCanParticipate or
    poll.adminsInclude(Session.user()) or
    (poll.membersInclude(Session.user()) and (!poll.group() or poll.group().membersCanVote))

  canReactToPoll: (poll) ->
    return false unless @isEmailVerified()
    return false unless poll
    poll.anyoneCanParticipate or
    poll.adminsInclude(Session.user()) or
    (poll.membersInclude(Session.user()) and (!poll.group() or poll.group().membersCanVote))

  canEditStance: (stance) ->
    Session.user() == stance.author()

  canEditThread: (thread) ->
    thread.adminsInclude(Session.user()) or
    (thread.membersInclude(Session.user()) and
     (thread.group().membersCanEditDiscussions or thread.author() == Session.user()))

  canCloseThread: (thread) ->
    !thread.closedAt && thread.adminsInclude(Session.user())

  canReopenThread: (thread) ->
    thread.closedAt && thread.adminsInclude(Session.user())

  canPinThread: (thread) ->
    !thread.closedAt && !thread.pinned && thread.adminsInclude(Session.user())

  canUnpinThread: (thread) ->
    !thread.closedAt && thread.pinned && thread.adminsInclude(Session.user())

  canExportThread: (thread) -> thread.adminsInclude(Session.user())

  canPinEvent: (event) ->
    !event.pinned && event.isSurface() && @canEditThread(event.discussion())

  canUnpinEvent: (event) ->
    event.pinned && @canEditThread(event.discussion())

  canMoveThread: (thread) ->
    thread.adminsInclude(Session.user()) or thread.author() == Session.user()

  canDeleteThread: (thread) ->
    thread.adminsInclude(Session.user()) or thread.author() == Session.user()

  canChangeGroupVolume: (group) ->
    group.membersInclude(Session.user())

  canAdminister: (model) ->
    switch model.constructor.singular
      when 'group'                     then model.adminsInclude(Session.user())
      when 'discussion', 'comment'     then model.discussion().adminsInclude(Session.user())
      when 'outcome', 'stance', 'poll' then model.poll().adminsInclude(Session.user())

  canChangeVolume: (discussion) -> discussion.membersInclude(Session.user())

  canManageGroupSubscription: (group) ->
    group.isParent() and
    group.adminsInclude(Session.user()) and
    group.subscriptionKind? and
    group.subscriptionKind != 'trial' and
    group.subscriptionPaymentMethod != 'manual'

  isCreatorOf: (group) ->
    Session.user().id == group.creatorId

  canStartThread: (group) ->
    group.adminsInclude(Session.user()) or
    (group.membersInclude(Session.user()) and group.membersCanStartDiscussions)

  canAnnounceTo: (model) ->
    if model.group()
      model.group().adminsInclude(Session.user()) or
      (model.membersInclude(Session.user()) and model.group().membersCanAnnounce)
    else
      model.adminsInclude(Session.user())

  canAddMembersToGroup: (group) ->
    group.adminsInclude(Session.user()) or
    (group.membersInclude(Session.user()) and group.membersCanAddMembers)

  canCreateSubgroups: (group) ->
    group.isParent() and
    (group.adminsInclude(Session.user()) or
    (group.membersInclude(Session.user()) and group.membersCanCreateSubgroups))

  canEditGroup: (group) ->
    group.adminsInclude(Session.user())

  canLeaveGroup: (group) ->
    Session.user().membershipFor(group)?

  canArchiveGroup: (group) ->
    group.adminsInclude(Session.user())

  canEditComment: (comment) ->
    comment.authorIs(Session.user()) and
    (comment.isMostRecent() or comment.group().membersCanEditComments) and
    comment.discussion().membersInclude(Session.user())

  canDeleteComment: (comment) ->
    comment.authorIs(Session.user()) or comment.discussion().adminsInclude(Session.user())

  canRemoveMembership: (membership) ->
    membership and
    (membership.user() == Session.user() or @canAdminister(membership.group()))

  canSetMembershipTitle: (membership) ->
    Session.user() == membership.user() or @canAdminister(membership.group())

  canResendMembership: (membership) ->
    membership and !membership.acceptedAt and membership.inviter() == Session.user()

  canManageMembershipRequests: (group) ->
    (group.membersCanAddMembers and group.membersInclude(Session.user())) or group.adminsInclude(Session.user())

  canViewPublicGroups: ->
    AppConfig.features.app.public_groups

  canStartGroups: ->
    @isEmailVerified() and (AppConfig.features.app.create_group || Session.user().isAdmin)

  canViewGroup: (group) ->
    !group.privacyIsSecret() or group.membersInclude(Session.user())

  canViewPrivateContent: (group) ->
    group.membersInclude(Session.user())

  canCreateContentFor: (group) ->
    group.membersInclude(Session.user())

  canViewMemberships: (group) ->
    group.membersInclude(Session.user())

  canViewPendingMemberships: (group) ->
    group.adminsInclude(Session.user())

  canViewPreviousPolls: (group) ->
    @canViewGroup(group)

  canJoinGroup: (group) ->
    return false if !@canViewGroup(group) or group.membersInclude(Session.user())
    group.membershipGrantedUpon == 'request' or group.parentOrSelf().adminsInclude(Session.user())

  canRequestMembership: (group) ->
    group.membershipGrantedUpon == 'approval' and
    @canViewGroup(group) and
    !group.membersInclude(Session.user()) and
    !@canJoinGroup(group)

  canTranslate: (model) ->
    AppConfig.inlineTranslation.isAvailable and
    Object.keys(model.translation).length == 0
    # _.includes(AppConfig.inlineTranslation.supportedLangs, Session.user().locale) and
    # !model.translation and Session.user().locale != model.author().locale

  canSubscribeToPoll: (poll) ->
    poll.membersInclude(Session.user())

  canEditPoll: (poll) ->
    poll.isActive() and poll.adminsInclude(Session.user())

  canDeletePoll: (poll) ->
    poll.adminsInclude(Session.user())

  canExportPoll: (poll) ->
    poll.adminsInclude(Session.user())

  canSetPollOutcome: (poll) ->
    poll.isClosed() and poll.adminsInclude(Session.user())

  canClosePoll: (poll) ->
    @canEditPoll(poll)

  canReopenPoll: (poll) ->
    poll.isClosed() and poll.adminsInclude(Session.user())
