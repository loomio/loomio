import AppConfig     from '@/shared/services/app_config';
import Records       from '@/shared/services/records';
import Session       from '@/shared/services/session';
import LmoUrlService from '@/shared/services/lmo_url_service';
import {intersection} from 'lodash';

let user = () => Session.user();

export default new class AbilityService {
  isNotEmailVerified() {
    return Session.isSignedIn() && !Session.user().emailVerified;
  }

  isEmailVerified() {
    return Session.isSignedIn() && Session.user().emailVerified;
  }

  isUser() {
    return (AppConfig.currentUserId != null);
  }

  canContactUser(user) {
    return Session.isSignedIn() &&
    (Session.user().id !== user.id) &&
    intersection(Session.user().groupIds(), user.groupIds()).length;
  }

  canAddComment(thread) {
    return !thread.closedAt &&
    thread.membersInclude(Session.user());
  }

  canRespondToComment(comment) {
    return !comment.discussion().closedAt &&
    !comment.discardedAt &&
    comment.discussion().membersInclude(Session.user());
  }

  canEdit(model) {
    return (model.isA('discussion') && this.canEditThread(model)) ||
    (model.isA('comment') && this.canEditComment(model)) ||
    (model.isA('poll') && this.canEditPoll(model)) ||
    (model.isA('stance') && this.canEditStance(model));
  }

  canEditStance(stance) {
    return Session.user() === stance.author();
  }

  canEditThread(thread) {
    return thread.adminsInclude(Session.user()) ||
    (!thread.closedAt && thread.membersInclude(Session.user()) &&
     (thread.group().membersCanEditDiscussions || (thread.author() === Session.user())));
  }

  canCloseThread(thread) {
    return !thread.closedAt && this.canEditThread(thread);
  }

  canReopenThread(thread) {
    return thread.closedAt && this.canEditThread(thread);
  }

  canPinThread(thread) {
    return !thread.closedAt && !thread.pinnedAt && this.canEditThread(thread);
  }

  canUnpinThread(thread) {
    return !thread.closedAt && thread.pinnedAt && this.canEditThread(thread);
  }

  canExportThread(thread) {
    return !thread.discardedAt && thread.membersInclude(Session.user());
  }

  canPinEvent(event) {
    return (event.depth === 1) &&
    !event.model().discardedAt &&
    !event.pinned &&
    !event.discussion().closedAt &&
    this.canEditThread(event.discussion());
  }

  canUnpinEvent(event) {
    return !event.discussion().closedAt &&
    event.pinned && this.canEditThread(event.discussion());
  }

  canMoveThread(thread) { return this.canEditThread(thread); }

  canDeleteThread(thread) {
    return thread.adminsInclude(Session.user()) || (thread.author() === Session.user());
  }

  canChangeGroupVolume(group) {
    return group.membersInclude(Session.user());
  }

  canAdminister(model) {
    switch (model.constructor.singular) {
      case 'group':                     return model.adminsInclude(Session.user());
      case 'discussion': case 'comment':     return model.discussion().adminsInclude(Session.user());
      case 'outcome': case 'stance': case 'poll': return model.poll().adminsInclude(Session.user());
    }
  }

  canChangeVolume(discussion) { return discussion.membersInclude(Session.user()); }

  canStartThread(group) {
    return group.adminsInclude(Session.user()) ||
    (group.membersInclude(Session.user()) && group.membersCanStartDiscussions);
  }

  canAnnounceDiscussion(discussion) {
    if (discussion.discardedAt || discussion.closedAt) { return false; }
    if (discussion.groupId) {
      return discussion.group().adminsInclude(Session.user()) ||
      (discussion.group().membersCanAnnounce && discussion.group().membersInclude(Session.user()));
    } else {
      return !discussion.id || discussion.adminsInclude(Session.user());
    }
  }

  canNotifyGroup(model) {
    return model.adminsInclude(Session.user()) ||
    (model.membersCanAnnounce && model.membersInclude(Session.user()));
  }

  canAnnounce(model) {
    if ((typeof model.isA === 'function' ? model.isA('poll') : undefined)) {
      return this.canAnnouncePoll(model);
    } else {
      return this.canAnnounceDiscussion(model);
    }
  }

  canAddGuests(model) {
    if ((typeof model.isA === 'function' ? model.isA('poll') : undefined)) {
      return this.canAddGuestsPoll(model);
    } else {
      return this.canAddGuestsDiscussion(model);
    }
  }

  canAddGuestsDiscussion(discussion) {
    if (discussion.groupId) {
      return discussion.group().adminsInclude(Session.user()) ||
      (discussion.group().membersCanAddGuests && discussion.group().membersInclude(Session.user()));
    } else {
      return !discussion.id || discussion.adminsInclude(Session.user());
    }
  }

  canAnnouncePoll(poll) {
    user = Session.user();
    if (poll.discardedAt) { return false; }
    if (poll.groupId) {
      return poll.group().adminsInclude(user) ||
      (poll.group().membersCanAnnounce && poll.adminsInclude(user)) ||
      (poll.group().membersCanAnnounce && !poll.specifiedVotersOnly && poll.membersInclude(user));
    } else {
      return poll.adminsInclude(user) ||
      (!poll.specifiedVotersOnly && poll.membersInclude(user));
    }
  }

  canAddMembersPoll(poll) {
    return poll.adminsInclude(user());
  }

  canAddGuestsPoll(poll) {
    if (poll.groupId) {
      return poll.group().adminsInclude(Session.user()) ||
      (poll.group().membersCanAddGuests && poll.group(Session.user()));
    } else {
      return poll.adminsInclude(Session.user());
    }
  }

  canAddMembersToGroup(group) {
    return group.adminsInclude(Session.user()) ||
    (group.membersInclude(Session.user()) && group.membersCanAddMembers);
  }

  canCreateSubgroups(group) {
    return group.isParent() &&
    (group.adminsInclude(Session.user()) ||
    (group.membersInclude(Session.user()) && group.membersCanCreateSubgroups));
  }

  canEditGroup(group) {
    return group.adminsInclude(Session.user());
  }

  canLeaveGroup(group) {
    return (Session.user().membershipFor(group) != null);
  }

  canArchiveGroup(group) {
    return group.adminsInclude(Session.user());
  }

  canEditOwnComment(comment) {
    return comment.authorIs(Session.user()) && this.canEditComment(comment);
  }

  canEditComment(comment) {
    return !comment.discussion().closedAt && (
      (comment.discussion().adminsInclude(Session.user()) && comment.group().adminsCanEditUserContent) ||
      (comment.authorIs(Session.user()) && comment.group().membersCanEditComments && comment.discussion().membersInclude(Session.user()))
    );
  }

  canDeleteComment(comment) {
    return (Records.comments.find({parentId: comment.id, parentType: 'Comment'}).length === 0) &&
    comment.discardedAt &&
    (
      comment.discussion().adminsInclude(Session.user()) ||
      (comment.group().membersCanDeleteComments && comment.authorIs(Session.user()))
    );
  }

  canDiscardComment(comment) {
    return !comment.discussion().closedAt &&
    !comment.discardedAt &&
    (
      comment.authorIs(Session.user()) ||
      comment.discussion().adminsInclude(Session.user())
    );
  }

  canUndiscardComment(comment) {
    return !comment.discussion().closedAt &&
    comment.discardedAt && (
      comment.authorIs(Session.user()) ||
      comment.discussion().adminsInclude(Session.user())
    );
  }

  canRemoveMembership(membership) {
    return membership &&
    ((membership.user() === Session.user()) || this.canAdminister(membership.group()));
  }

  canSetMembershipTitle(membership) {
    return (Session.user() === membership.user()) || this.canAdminister(membership.group());
  }

  canResendMembership(membership) {
    return membership && !membership.acceptedAt && this.canAdminister(membership.group());
  }

  canManageMembershipRequests(group) {
    return (group.membersCanAddMembers && group.membersInclude(Session.user())) || group.adminsInclude(Session.user());
  }

  canViewPublicGroups() {
    return AppConfig.features.app.public_groups;
  }

  canStartGroups() {
    return this.isEmailVerified() && (AppConfig.features.app.create_group || Session.user().isAdmin);
  }

  canViewGroup(group) {
    return !group.privacyIsSecret() || group.membersInclude(Session.user());
  }

  canViewPrivateContent(group) {
    return group.membersInclude(Session.user());
  }

  canJoinGroup(group) {
    if (group.subscription.plan === 'demo') { return false; }
    if (!this.canViewGroup(group) || group.membersInclude(Session.user())) { return false; }
    return (group.membershipGrantedUpon === 'request') || group.parentOrSelf().adminsInclude(Session.user());
  }

  canRequestMembership(group) {
    return (group.membershipGrantedUpon === 'approval') &&
    this.canViewGroup(group) &&
    !group.membersInclude(Session.user()) &&
    !this.canJoinGroup(group);
  }

  canTranslate(model) {
    if (model.discardedAt) { return false; }
    return (AppConfig.inlineTranslation.isAvailable &&
    (Object.keys(model.translation).length === 0) &&
    !model.isBlank() &&
    (model.contentLocale && (model.contentLocale !== Session.user().locale))) ||
    (!model.contentLocale && (model.author().locale !== Session.user().locale));
  }

  canStartPoll(model) {
    return model.adminsInclude(Session.user()) ||
    (model.membersInclude(Session.user()) && model.group().membersCanRaiseMotions);
  }

  canParticipateInPoll(poll) {
    if (!poll) { return false; }
    if (poll.closedAt) { return false; }
    return poll.myStance() || (!poll.specifiedVotersOnly && poll.membersInclude(Session.user()));
  }

  canMovePoll(poll) {
    return (!poll.discussionId || !poll.discussion().closedAt) &&
    !poll.discussionId && poll.adminsInclude(Session.user());
  }

  canEditPoll(poll) {
    return (!poll.discussionId || !poll.discussion().closedAt) &&
    poll.adminsInclude(Session.user()) && !poll.closedAt;
  }

  canDeletePoll(poll) {
    return (!poll.discussionId || !poll.discussion().closedAt) &&
    !poll.discardedAt && poll.adminsInclude(Session.user());
  }

  canExportPoll(poll) {
    return !poll.discardedAt && poll.membersInclude(Session.user()) && (poll.closedAt || (poll.hideResults !== "until_closed"));
  }

  canAddPollToThread(poll) {
    return !poll.discardedAt && !poll.discussionId && poll.adminsInclude(Session.user());
  }

  canSetPollOutcome(poll) {
    return (!poll.discussionId || !poll.discussion().closedAt) &&
    !poll.discardedAt &&
    poll.closedAt &&
    poll.adminsInclude(Session.user());
  }

  canClosePoll(poll) {
    return !!poll.closingAt && !poll.discardedAt && !poll.closedAt && this.canEditPoll(poll);
  }

  canReopenPoll(poll) {
    return !poll.discardedAt && poll.closedAt && !poll.anonymous && poll.adminsInclude(Session.user());
  }
}
