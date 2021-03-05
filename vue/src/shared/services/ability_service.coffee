import AppConfig     from '@/shared/services/app_config'
import Records       from '@/shared/services/records'
import Session       from '@/shared/services/session'
import LmoUrlService from '@/shared/services/lmo_url_service'
import {intersection} from 'lodash'

user = -> Session.user()

export default new class AbilityService
  isNotEmailVerified: ->
    Session.isSignedIn() and !Session.user().emailVerified

  isEmailVerified: ->
    Session.isSignedIn() && Session.user().emailVerified

  isUser: ->
    AppConfig.currentUserId?

  canContactUser: (user) ->
    Session.isSignedIn() &&
    Session.user().id != user.id &&
    intersection(Session.user().groupIds(), user.groupIds()).length

  canAddComment: (thread) ->
    thread.membersInclude(Session.user())

  canRespondToComment: (comment) ->
    !comment.discardedAt &&
    comment.discussion().membersInclude(Session.user())

  canEditStance: (stance) ->
    Session.user() == stance.author()

  canEditThread: (thread) ->
    thread.adminsInclude(Session.user()) or
    (thread.membersInclude(Session.user()) and
     (thread.group().membersCanEditDiscussions or thread.author() == Session.user()))

  canCloseThread: (thread) ->
    !thread.closedAt && @canEditThread(thread)

  canReopenThread: (thread) ->
    thread.closedAt && @canEditThread(thread)

  canPinThread: (thread) ->
    !thread.closedAt && !thread.pinned && @canEditThread(thread)

  canUnpinThread: (thread) ->
    !thread.closedAt && thread.pinned && @canEditThread(thread)

  canExportThread: (thread) ->
    !thread.discardedAt && thread.membersInclude(Session.user())

  canPinEvent: (event) ->
    !event.model().discardedAt &&
    !event.pinned && event.isSurface() && @canEditThread(event.discussion())

  canUnpinEvent: (event) ->
    event.pinned && @canEditThread(event.discussion())

  canMoveThread: (thread) -> @canEditThread(thread)

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

  canStartThread: (group) ->
    group.adminsInclude(user()) or
    (group.membersInclude(user()) and group.membersCanStartDiscussions)

  canAnnounceDiscussion: (discussion) ->
    return false if discussion.discardedAt
    if discussion.groupId
      discussion.group().adminsInclude(user()) or
      (discussion.group().membersCanAnnounce and discussion.group().membersInclude(user()))
    else
      !discussion.id || discussion.adminsInclude(user())

  canNotifyGroup: (model) ->
    model.adminsInclude(Session.user()) ||
    (model.membersCanAnnounce && model.membersInclude(Session.user()))

  canAnnounce: (model) ->
    if model.isA? 'poll'
      @canAnnouncePoll(model)
    else
      @canAnnounceDiscussion(model)

  canAddGuests: (model) ->
    if model.isA? 'poll'
      @canAddGuestsPoll(model)
    else
      @canAddGuestsDiscussion(model)

  canAddGuestsDiscussion: (discussion) ->
    if discussion.groupId
      discussion.group().adminsInclude(user()) ||
      (discussion.group().membersCanAddGuests && discussion.membersInclude(user()))
    else
      !discussion.id || discussion.adminsInclude(user())

  canAnnouncePoll: (poll) ->
    return false if poll.discardedAt
    if poll.groupId
      poll.group().adminsInclude(user()) ||
      (poll.group().membersCanAnnounce && poll.adminsInclude(user())) ||
      (poll.group().membersCanAnnounce && !poll.specifiedVotersOnly && poll.membersInclude(user()))
    else
      poll.adminsInclude(user())

  canAddMembersPoll: (poll) ->
    poll.adminsInclude(user())

  canAddGuestsPoll: (poll) ->
    if poll.groupId
      poll.group().adminsInclude(user()) ||
      (poll.group().membersCanAddGuests && poll.adminsInclude(user())) ||
      (poll.group().membersCanAddGuests && !poll.specifiedVotersOnly && poll.membersInclude(user()))
    else
      poll.adminsInclude(user())

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

  canEditOwnComment: (comment) ->
    comment.authorIs(Session.user()) && @canEditComment(comment)

  canEditComment: (comment) ->
    (comment.discussion().adminsInclude(Session.user()) and comment.group().adminsCanEditUserContent) or

    (comment.authorIs(Session.user()) and
     comment.group().membersCanEditComments and
     comment.discussion().membersInclude(Session.user()))

  canDeleteComment: (comment) ->
    (comment.group().membersCanDeleteComments && comment.authorIs(Session.user())) ||
    comment.discussion().adminsInclude(Session.user())

  canDiscardComment: (comment) ->
    !comment.discardedAt && @canDeleteComment(comment)

  canUndiscardComment: (comment) ->
    comment.discardedAt && @canDeleteComment(comment)

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

  canJoinGroup: (group) ->
    return false if !@canViewGroup(group) or group.membersInclude(Session.user())
    group.membershipGrantedUpon == 'request' or group.parentOrSelf().adminsInclude(Session.user())

  canRequestMembership: (group) ->
    group.membershipGrantedUpon == 'approval' and
    @canViewGroup(group) and
    !group.membersInclude(Session.user()) and
    !@canJoinGroup(group)

  canTranslate: (model) ->
    return false if model.discardedAt
    AppConfig.inlineTranslation.isAvailable &&
    Object.keys(model.translation).length == 0 &&
    (model.contentLocale && model.contentLocale != Session.user().locale) ||
    (!model.contentLocale && model.author().locale != Session.user().locale)

  canStartPoll: (model) ->
    model.adminsInclude(Session.user()) or
    (model.membersInclude(Session.user()) and model.group().membersCanRaiseMotions)

  canParticipateInPoll: (poll) ->
    return false unless poll
    return false unless poll.isActive()
    poll.anyoneCanParticipate or
    poll.myStance() or
    (!poll.specifiedVotersOnly and poll.membersInclude(Session.user()))

  canMovePoll: (poll) ->
    !poll.discussionId && poll.adminsInclude(Session.user())

  canEditPoll: (poll) ->
    poll.isActive() and poll.adminsInclude(Session.user())

  canDeletePoll: (poll) ->
    !poll.discardedAt && poll.adminsInclude(Session.user())

  canExportPoll: (poll) ->
    !poll.discardedAt && poll.membersInclude(Session.user())

  canAddPollToThread: (poll) ->
    !poll.discardedAt && !poll.discussionId && poll.adminsInclude(Session.user())

  canSetPollOutcome: (poll) ->
    !poll.discardedAt && poll.closedAt && poll.adminsInclude(Session.user())

  canClosePoll: (poll) ->
    !poll.discardedAt && !poll.closedAt && @canEditPoll(poll)

  canReopenPoll: (poll) ->
    !poll.discardedAt && poll.closedAt && !poll.anonymous && poll.adminsInclude(Session.user())
