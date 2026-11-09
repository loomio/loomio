import Session from '@/shared/services/session';

// Mirrors the server's Ability::Reaction using the raw state the client
// receives. test/contracts/reaction_ability_contract_test.rb checks these rules.
export default {
  // Reacting to something in the topic.
  create(topic) {
    return topic.group().isEnabled() && !topic.lockedAt && topic.allowReactions && topic.membersInclude(Session.user());
  }
};
