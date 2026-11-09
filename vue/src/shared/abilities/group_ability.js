import Session from '@/shared/services/session';

// Mirrors the server's Ability::Group, and MembershipRequest :create, using the
// raw state the client receives. test/contracts/group_ability_contract_test.rb
// checks these rules. Server admins manage any group's membership.
const isServerAdmin = () => !!Session.user().isAdmin;

export default {
  show(group) {
    return !group.isDiscarded() && (group.isVisibleToPublic ||
      group.membersInclude(Session.user()) ||
      (group.isVisibleToParentMembers && group.parent().membersInclude(Session.user())));
  },

  seePrivateContent(group) {
    return !group.isDiscarded() && (group.privacyIsOpen() || group.membersInclude(Session.user()) ||
      (group.isVisibleToParentMembers && group.parentOrSelf().membersInclude(Session.user())));
  },

  update(group) {
    return group.isEnabled() && group.adminsInclude(Session.user());
  },

  destroy(group) {
    return isServerAdmin() || group.adminsInclude(Session.user());
  },

  setVolume(group) {
    return group.membersInclude(Session.user());
  },

  addMembers(group) {
    return group.isEnabled() && (isServerAdmin() || group.adminsInclude(Session.user()) ||
      (group.membersInclude(Session.user()) && group.membersCanAddMembers));
  },

  addGuests(group) {
    const user = Session.user();
    return !!user.emailVerified && !!group.subscription?.active &&
      (group.adminsInclude(user) || (group.membersCanAddGuests && group.membersInclude(user)));
  },

  manageMembershipRequests(group) {
    return group.isEnabled() && (isServerAdmin() || (group.membersCanAddMembers && group.membersInclude(Session.user())) ||
      group.adminsInclude(Session.user()));
  },

  notify(group) {
    return group.isEnabled() && (group.adminsInclude(Session.user()) ||
      (group.membersCanAnnounce && group.membersInclude(Session.user())));
  },

  addSubgroup(group) {
    return group.isEnabled() && group.isParent() && (group.adminsInclude(Session.user()) ||
      (group.membersInclude(Session.user()) && group.membersCanCreateSubgroups));
  },

  join(group) {
    if (!group.isEnabled() || !this.show(group) || !Session.user().emailVerified) { return false; }
    return (group.membershipGrantedUpon === 'request') || (!!group.parentId && group.parent().adminsInclude(Session.user()));
  },

  requestMembership(group) {
    return (group.membershipGrantedUpon === 'approval') && this.show(group);
  }
};
