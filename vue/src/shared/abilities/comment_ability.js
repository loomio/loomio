import Records from '@/shared/services/records';
import Session from '@/shared/services/session';

// Mirrors the server's Ability::Comment using the raw state the client
// receives. test/contracts/comment_ability_contract_test.rb checks these rules.
// Conditions that only shape the interface, such as offering deletion only
// after a comment is discarded, belong in the action that calls these.
export default {
  // A new top-level comment in the topic.
  canCreate(topic) {
    return topic.group().isEnabled() && !topic.lockedAt && topic.allowComments && topic.membersInclude(Session.user());
  },

  // A reply to an existing comment.
  canReply(comment) {
    return this.canCreate(comment.topic());
  },

  canUpdate(comment) {
    const topic = comment.topic();
    return topic.group().isEnabled() && !topic.lockedAt && !comment.discardedAt && (
      (topic.adminsInclude(Session.user()) && comment.group().adminsCanEditUserContent) ||
      (comment.authorIs(Session.user()) && comment.group().membersCanEditComments && topic.membersInclude(Session.user()))
    );
  },

  canDiscard(comment) {
    const topic = comment.topic();
    return topic.group().isEnabled() && !topic.lockedAt && (
      (comment.authorIs(Session.user()) && topic.membersInclude(Session.user())) ||
      topic.adminsInclude(Session.user())
    );
  },

  canUndiscard(comment) {
    const topic = comment.topic();
    return topic.group().isEnabled() && !topic.lockedAt && (
      (comment.authorIs(Session.user()) && comment.discardedBy === Session.userId && topic.membersInclude(Session.user())) ||
      topic.adminsInclude(Session.user())
    );
  },

  canDestroy(comment) {
    const topic = comment.topic();
    return topic.group().isEnabled() && !topic.lockedAt &&
      (Records.comments.find({parentId: comment.id, parentType: 'Comment'}).length === 0) && (
        topic.adminsInclude(Session.user()) ||
        (comment.authorIs(Session.user()) && topic.membersInclude(Session.user()) && comment.group().membersCanDeleteComments)
      );
  }
};
