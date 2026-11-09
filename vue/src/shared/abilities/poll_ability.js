import Session from '@/shared/services/session';
import TopicAbility from '@/shared/abilities/topic_ability';

// Mirrors the server's Ability::Poll using the raw poll state the client
// receives. Method names match the server actions, and
// test/contracts/poll_ability_contract_test.rb checks these rules against it.
export default {
  update(poll) {
    return poll.group().isEnabled() && !poll.topic().lockedAt &&
      !poll.discardedAt && poll.adminsInclude(Session.user()) && !poll.closedAt;
  },

  destroy(poll) {
    return poll.group().isEnabled() && !poll.topic().lockedAt &&
      !poll.discardedAt && poll.adminsInclude(Session.user());
  },

  // Closing ends voting early, which a locked thread does not prevent.
  close(poll) {
    return poll.group().isEnabled() && poll.isVotable() && poll.adminsInclude(Session.user());
  },

  reopen(poll) {
    return poll.group().isEnabled() && !poll.topic().lockedAt && !poll.discardedAt && !!poll.closedAt &&
      poll.hideResults !== 'until_closed' && !poll.anonymous && poll.adminsInclude(Session.user());
  },

  // Anyone who can see the poll, which is every poll the client holds.
  export(poll) {
    return !poll.discardedAt && poll.resultsAvailable();
  },

  // Starting a new poll in the topic.
  create(topic) {
    if (topic.topicableType === 'Poll') { return false; }
    if (topic.activePollsCount > 0 && topic.pollsOneAtATime) { return false; }
    return topic.group().isEnabled() && (topic.adminsInclude(Session.user()) ||
      (topic.group().membersCanRaiseMotions && topic.membersInclude(Session.user())));
  },

  announce(poll) {
    const user = Session.user();
    if (poll.discardedAt) { return false; }
    if (poll.groupId) {
      return poll.group().isEnabled() && (poll.group().adminsInclude(user) ||
        (poll.group().membersCanAnnounce && poll.adminsInclude(user)));
    } else {
      return poll.adminsInclude(user) || (!poll.specifiedVotersOnly && poll.membersInclude(user));
    }
  },

  remind(poll) {
    return poll.isOpened() && this.announce(poll);
  },

  addVoters(poll) {
    return poll.group().isEnabled() && poll.adminsInclude(Session.user());
  },

  // Poll guests join the poll's thread, so the thread's rule applies.
  addGuests(poll) {
    return TopicAbility.addGuests(poll.topic());
  },

  viewAnonymousVoters(poll) {
    return poll.anonymous && poll.showResults();
  }
};
