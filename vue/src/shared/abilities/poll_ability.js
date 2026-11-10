import Session from '@/shared/services/session';
import TopicAbility from '@/shared/abilities/topic_ability';

// Mirrors the server's Ability::Poll using the raw poll state the client
// receives. Each method is a server action with a can prefix, and
// test/contracts/poll_ability_contract_test.rb checks these rules against it.
export default {
  canUpdate(poll) {
    return poll.group().isEnabled() && !poll.topic().lockedAt &&
      !poll.discardedAt && poll.adminsInclude(Session.user()) && !poll.closedAt;
  },

  canDestroy(poll) {
    return poll.group().isEnabled() && !poll.topic().lockedAt &&
      !poll.discardedAt && poll.adminsInclude(Session.user());
  },

  // Closing ends voting early, which a locked thread does not prevent.
  canClose(poll) {
    return poll.group().isEnabled() && poll.isVotable() && poll.adminsInclude(Session.user());
  },

  canReopen(poll) {
    return poll.group().isEnabled() && !poll.topic().lockedAt && !poll.discardedAt && !!poll.closedAt &&
      poll.hideResults !== 'until_closed' && !poll.anonymous && poll.adminsInclude(Session.user());
  },

  // Anyone who can see the poll, which is every poll the client holds.
  canExport(poll) {
    return !poll.discardedAt && poll.resultsAvailable();
  },

  // Starting a new poll in the topic.
  canCreate(topic) {
    if (topic.topicableType === 'Poll') { return false; }
    if (topic.activePollsCount > 0 && topic.pollsOneAtATime) { return false; }
    return topic.group().isEnabled() && (topic.adminsInclude(Session.user()) ||
      (topic.group().membersCanRaiseMotions && topic.membersInclude(Session.user())));
  },

  canAnnounce(poll) {
    const user = Session.user();
    if (poll.discardedAt) { return false; }
    if (poll.groupId) {
      return poll.group().isEnabled() && (poll.group().adminsInclude(user) ||
        (poll.group().membersCanAnnounce && poll.adminsInclude(user)));
    } else {
      return poll.adminsInclude(user) || (!poll.specifiedVotersOnly && poll.membersInclude(user));
    }
  },

  canRemind(poll) {
    return poll.isOpened() && this.canAnnounce(poll);
  },

  canAddVoters(poll) {
    return poll.group().isEnabled() && poll.adminsInclude(Session.user());
  },

  // Poll guests join the poll's thread, so the thread's rule applies.
  canAddGuests(poll) {
    return TopicAbility.canAddGuests(poll.topic());
  },

  canViewAnonymousVoters(poll) {
    return poll.anonymous && poll.showResults();
  }
};
