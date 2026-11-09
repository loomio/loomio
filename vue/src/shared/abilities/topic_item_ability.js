import Session from '@/shared/services/session';

const TAGGABLE_KINDS = ['new_discussion', 'poll_created', 'outcome_created', 'new_comment'];

// Mirrors the server's Ability::TopicItem using the raw state the client
// receives. test/contracts/topic_item_ability_contract_test.rb checks these rules.
// Thread admins moderate pins, even in locked threads.
export default {
  pin(item) {
    const topic = item.topic();
    return topic.group().isEnabled() && topic.adminsInclude(Session.user());
  },

  unpin(item) {
    return this.pin(item);
  },

  updateTags(item) {
    if (!TAGGABLE_KINDS.includes(item.kind)) { return false; }
    const topic = item.topic();
    const user = Session.user();
    if (!Session.isSignedIn() || !topic.group().isEnabled() || topic.lockedAt || topic.discardedAt || item.model().discardedAt) { return false; }
    return topic.membersInclude(user) && (topic.adminsInclude(user) || item.model().authorId === user.id ||
      topic.group().membersCanEditDiscussions);
  }
};
