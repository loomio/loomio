import AppConfig     from '@/shared/services/app_config';
import Records       from '@/shared/services/records';
import Session       from '@/shared/services/session';
import LmoUrlService from '@/shared/services/lmo_url_service';
import PollAbility   from '@/shared/abilities/poll_ability';
import CommentAbility from '@/shared/abilities/comment_ability';
import DiscussionAbility from '@/shared/abilities/discussion_ability';
import TopicAbility from '@/shared/abilities/topic_ability';
import {intersection} from 'lodash-es';

export default new class AbilityService {
  isNotEmailVerified() {
    return Session.isSignedIn() && !Session.user().emailVerified;
  }

  isEmailVerified() {
    return Session.isSignedIn() && Session.user().emailVerified;
  }

  isUser() {
    return Session.isSignedIn();
  }

  canContactUser(user) {
    return Session.isSignedIn() &&
    (Session.userId !== user.id) &&
    intersection(Session.user().groupIds(), user.groupIds()).length;
  }

  canAddReaction(topic) {
    return topic.group().isEnabled() && !topic.lockedAt && topic.allowReactions && topic.membersInclude(Session.user());
  }

  canAttachFiles(model) {
    const kind = model.constructor.singular;
    if (!['discussion', 'poll', 'comment', 'stance', 'outcome'].includes(kind)) { return true; }
    if (['discussion', 'poll'].includes(kind) && !model.topicId) { return true; }
    const topic = kind === 'outcome' ? model.poll().topic() : model.topic();
    return !topic.attachmentsAdminOnly || topic.adminsInclude(Session.user());
  }

  canEdit(model) {
    if (!model) { return false; }

    return (model.isA('discussion') && DiscussionAbility.update(model)) ||
    (model.isA('comment') && CommentAbility.update(model)) ||
    (model.isA('poll') && PollAbility.update(model)) ||
    (model.isA('stance') && this.canEditStance(model));
  }

  canEditStance(stance) {
    return stance.poll().group().isEnabled() && Session.user() === stance.author();
  }

  canAdminTags(topic) {
    const group = topic.group();
    return group.isEnabled() && group.parentOrSelf().adminsInclude(Session.user());
  }

  canCreateTags(group) {
    const user = Session.user();
    return group.parentOrSelf().adminsInclude(user) ||
      group.adminsInclude(user) ||
      !!(group.membersCanCreateTags && group.membersInclude(user));
  }

  canChangeGroupVolume(group) {
    return group.membersInclude(Session.user());
  }

  canAdminister(model) {
    if (model.constructor.singular == 'group') {
      return model.isEnabled() && model.adminsInclude(Session.user());
    } else {
      return model.topic().group().isEnabled() && model.topic().adminsInclude(Session.user());
    }
  }

  canNotifyGroup(model) {
    return model.isEnabled() && (model.adminsInclude(Session.user()) ||
    (model.membersCanAnnounce && model.membersInclude(Session.user())));
  }

  canAnnounce(model) {
    if (model.isA('group')) { return this.canNotifyGroup(model); }
    if (model.isA('poll')) { return this.canAnnouncePoll(model); }
    if (model.isA('topic')) { return !model.lockedAt && TopicAbility.announce(model); }
    return DiscussionAbility.announce(model);
  }

  canAddGuests(model) {
    if (model.isA('group')) { return this.canAddMembersToGroup(model); }
    if (model.isA('poll')) { return this.canAddGuestsPoll(model); }
    if (model.isA('topic')) { return TopicAbility.addGuests(model); }
    return this.canAddGuestsDiscussion(model);
  }

  canAddGuestsDiscussion(discussion) {
    if (discussion.groupId) {
      return discussion.group().isEnabled() && !!discussion.group().parentOrSelf().subscription?.allow_guests &&
      (discussion.group().adminsInclude(Session.user()) ||
      (discussion.group().membersCanAddGuests && discussion.group().membersInclude(Session.user())));
    } else {
      return !discussion.id || discussion.topic().adminsInclude(Session.user());
    }
  }

  canAnnouncePoll(poll) {
    const user = Session.user();
    if (poll.discardedAt) { return false; }
    if (poll.groupId) {
      return poll.group().isEnabled() && (poll.group().adminsInclude(user) ||
      (poll.group().membersCanAnnounce && poll.adminsInclude(user)))
    } else {
      return poll.adminsInclude(user) ||
      (!poll.specifiedVotersOnly && poll.membersInclude(user));
    }
  }

  canAddMembersPoll(poll) {
    return poll.group().isEnabled() && poll.adminsInclude(Session.user());
  }

  canAddGuestsPoll(poll) {
    if (poll.groupId) {
      return poll.group().isEnabled() && !!poll.group().parentOrSelf().subscription?.allow_guests &&
      (poll.group().adminsInclude(Session.user()) ||
      (poll.group().membersCanAddGuests && poll.adminsInclude(Session.user())));
    } else {
      return poll.adminsInclude(Session.user());
    }
  }

  canAddMembersToGroup(group) {
    return group.isEnabled() && (group.adminsInclude(Session.user()) ||
    (group.membersInclude(Session.user()) && group.membersCanAddMembers));
  }

  canCreateSubgroups(group) {
    return group.isEnabled() && group.isParent() &&
    (group.adminsInclude(Session.user()) ||
    (group.membersInclude(Session.user()) && group.membersCanCreateSubgroups));
  }

  canEditGroup(group) {
    return group.isEnabled() && group.adminsInclude(Session.user());
  }

  canLeaveGroup(group) {
    return (Session.user().membershipFor(group) != null);
  }

  canDeleteGroup(group) {
    return group.adminsInclude(Session.user());
  }

  canRemoveMembership(membership) {
    return membership &&
    ((membership.user() === Session.user()) || membership.group().adminsInclude(Session.user()));
  }

  canSetMembershipTitle(membership) {
    return membership.group().isEnabled() && ((Session.user() === membership.user()) || this.canAdminister(membership.group()));
  }

  canResendMembership(membership) {
    return membership && membership.group().isEnabled() && !membership.acceptedAt && this.canAdminister(membership.group());
  }

  canManageMembershipRequests(group) {
    return group.isEnabled() && ((group.membersCanAddMembers && group.membersInclude(Session.user())) || group.adminsInclude(Session.user()));
  }

  canStartGroups() {
    return this.isEmailVerified() && (AppConfig.features.app.create_group || Session.user().isAdmin);
  }

  canViewGroup(group) {
    return !group.isDiscarded() && (group.isVisibleToPublic ||
      group.membersInclude(Session.user()) ||
      (group.isVisibleToParentMembers && group.parent().membersInclude(Session.user())));
  }

  canViewPrivateContent(group) {
    return group.membersInclude(Session.user());
  }

  canJoinGroup(group) {
    if (!group.isEnabled() || !this.canViewGroup(group) || group.membersInclude(Session.user())) { return false; }
    return (group.membershipGrantedUpon === 'request') || group.parentOrSelf().adminsInclude(Session.user());
  }

  canRequestMembership(group) {
    return group.isEnabled() &&
    (group.membershipGrantedUpon === 'approval') &&
    this.canViewGroup(group) &&
    !group.membersInclude(Session.user()) &&
    !this.canJoinGroup(group);
  }

  canTranslate(model) {
    return !model.discardedAt &&
           AppConfig.inlineTranslation.isAvailable &&
           !model.translationId &&
           model.contentLocale &&
           model.contentLocale !== Session.user().locale &&
           !model.isBlank() &&
           Session.isSignedIn()
  }

  canUntranslate(model) {
    return !!model.translationId
  }

  canStartPoll(topic) {
    if (topic.topicableType === 'Poll') { return false; }
    if (topic.activePollsCount > 0 && topic.pollsOneAtATime) { return false; }
    return topic.group().isEnabled() && (topic.adminsInclude(Session.user()) ||
           (topic.membersCanRaiseMotions && topic.membersInclude(Session.user()))
    )
  }

  // Matches the server's view_anonymous_voters: everyone who can see the results.
  canViewAnonymousVoters(poll) {
    return poll.anonymous && poll.showResults();
  }

  canSetPollOutcome(poll) {
    return poll.group().isEnabled() &&
    !poll.discardedAt &&
    !!poll.closedAt &&
    (poll.adminsInclude(Session.user()) ||
     (poll.group().membersCanEditDiscussions && poll.membersInclude(Session.user())));
  }
}
