import Session from '@/shared/services/session';

// Mirrors the server's Ability::Stance using the raw state the client
// receives. test/contracts/stance_ability_contract_test.rb checks these rules.
// Conditions that only shape the interface, such as offering "change vote"
// after a vote is cast, belong in the action that calls these.
export default {
  canUpdate(stance) {
    return !!stance &&
      stance.latest &&
      !stance.revokedAt &&
      (stance.poll().myStanceId === stance.id) &&
      stance.poll().isVotable();
  },

  canUncast(stance) {
    return this.canUpdate(stance) && !!stance.castAt;
  },

  canRedact(stance) {
    const poll = stance.poll();
    return poll.group().isEnabled() && !stance.redactedAt && poll.adminsInclude(Session.user());
  },

  canUnredact(stance) {
    const poll = stance.poll();
    return poll.group().isEnabled() && !!stance.redactedAt && poll.adminsInclude(Session.user());
  }
};
