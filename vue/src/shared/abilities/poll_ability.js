import Session from '@/shared/services/session';

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

  export(poll) {
    return !poll.discardedAt && poll.membersInclude(Session.user()) && poll.resultsAvailable();
  }
};
