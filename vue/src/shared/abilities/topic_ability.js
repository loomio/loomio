import Session from '@/shared/services/session';

// Mirrors the server's Ability::Topic using the raw state the client
// receives. test/contracts/topic_ability_contract_test.rb checks these rules.
export default {
  canUpdate(topic) {
    return topic.group().isEnabled() && topic.adminsInclude(Session.user());
  },

  canAttachFiles(topic) {
    return topic.group().isEnabled() && (topic.adminsInclude(Session.user()) ||
      (!topic.attachmentsAdminOnly && topic.membersInclude(Session.user())));
  },

  canAnnounce(topic) {
    if (topic.groupId) {
      return topic.group().isEnabled() && (topic.group().adminsInclude(Session.user()) ||
        (topic.group().membersCanAnnounce && topic.group().membersInclude(Session.user())));
    } else {
      return topic.adminsInclude(Session.user());
    }
  },

  // The organisation's subscription decides whether guests are allowed at all.
  canAddGuests(topic) {
    if (topic.groupId) {
      return topic.group().isEnabled() && !!topic.group().parentOrSelf().subscription?.allow_guests &&
        (topic.group().adminsInclude(Session.user()) ||
          (topic.group().membersCanAddGuests && topic.group().membersInclude(Session.user())));
    } else {
      return topic.adminsInclude(Session.user());
    }
  },

  canMove(topic) {
    return topic.group().isEnabled() && topic.adminsInclude(Session.user());
  },

  canMoveComments(topic) {
    return topic.group().isEnabled() && topic.adminsInclude(Session.user());
  },

  canUpdateTags(topic) {
    const user = Session.user();
    return Session.isSignedIn() && topic.group().isEnabled() && !topic.lockedAt && !topic.discardedAt &&
      topic.membersInclude(user) && (topic.adminsInclude(user) || topic.topicable().authorId === user.id ||
        topic.group().membersCanEditDiscussions);
  }
};
