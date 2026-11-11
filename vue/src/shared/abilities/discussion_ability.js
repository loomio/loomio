import Session from '@/shared/services/session';

// Mirrors the server's Ability::Discussion using the raw state the client
// receives. test/contracts/discussion_ability_contract_test.rb checks these rules.
export default {
  // Starting a new thread in the group.
  canCreate(group) {
    const user = Session.user();
    return group.isEnabled() && (group.adminsInclude(user) ||
      (group.membersInclude(user) && group.membersCanStartDiscussions) ||
      (Session.isSignedIn() && user.emailVerified && !group.privacyIsSecret() &&
        group.nonMembersCanStartDiscussions && !group.membersInclude(user)));
  },

  // Thread admins can always edit. Others need current access to an unlocked
  // thread, and either authorship or the members-can-edit setting.
  canUpdate(discussion) {
    const topic = discussion.topic();
    return topic.group().isEnabled() && !discussion.discardedAt && (topic.adminsInclude(Session.user()) ||
      (!topic.lockedAt && topic.membersInclude(Session.user()) &&
        (discussion.authorIs(Session.user()) || topic.group().membersCanEditDiscussions)));
  },

  canAnnounce(discussion) {
    if (discussion.discardedAt) { return false; }
    if (discussion.groupId) {
      return discussion.group().isEnabled() && (discussion.group().adminsInclude(Session.user()) ||
        (discussion.group().membersCanAnnounce && discussion.group().membersInclude(Session.user())));
    } else {
      return !discussion.id || discussion.topic().adminsInclude(Session.user());
    }
  },

  canAddGuests(discussion) {
    if (discussion.groupId) {
      const group = discussion.group();
      return group.isEnabled() && !!group.parentOrSelf().subscription?.allow_guests &&
        (group.adminsInclude(Session.user()) || (group.membersCanAddGuests && group.membersInclude(Session.user())));
    } else {
      return !discussion.id || discussion.topic().adminsInclude(Session.user());
    }
  }
};
