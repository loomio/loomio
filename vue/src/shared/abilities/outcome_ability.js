import Session from '@/shared/services/session';

// Mirrors the server's Ability::Outcome using the raw state the client
// receives. test/contracts/poll_audience_ability_contract_test.rb checks it.
export default {
  // Outcomes conclude a vote, so they need a closed poll that still exists,
  // in a thread that is not locked.
  canCreate(poll) {
    return poll.group().isEnabled() && !poll.discardedAt && !!poll.closedAt &&
      !(poll.topicId && poll.topic().lockedAt) &&
      (poll.adminsInclude(Session.user()) ||
        (poll.group().membersCanEditDiscussions && poll.membersInclude(Session.user())));
  },

  // The server uses one rule for creating and updating an outcome.
  canUpdate(outcome) {
    return this.canCreate(outcome.poll());
  }
};
