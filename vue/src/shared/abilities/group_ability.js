import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';

// Mirrors the server's Ability::Group, and MembershipRequest :create, using the
// raw state the client receives. test/contracts/group_ability_contract_test.rb
// checks these rules. Server admins manage any group's membership.
const isServerAdmin = () => !!Session.user().isAdmin;

export default {
  // Starting a new top-level group.
  canCreate() {
    const user = Session.user();
    return Session.isSignedIn() && !!user.emailVerified && (AppConfig.features.app.create_group || !!user.isAdmin);
  },

  canShow(group) {
    return !group.isDiscarded() && (group.isVisibleToPublic ||
      group.membersInclude(Session.user()) ||
      (group.isVisibleToParentMembers && group.parent().membersInclude(Session.user())));
  },

  canSeePrivateContent(group) {
    return !group.isDiscarded() && (group.privacyIsOpen() || group.membersInclude(Session.user()) ||
      (group.isVisibleToParentMembers && group.parentOrSelf().membersInclude(Session.user())));
  },

  canUpdate(group) {
    return group.isEnabled() && group.adminsInclude(Session.user());
  },

  canDestroy(group) {
    return isServerAdmin() || group.adminsInclude(Session.user());
  },

  canSetVolume(group) {
    return group.membersInclude(Session.user());
  },

  canAddMembers(group) {
    return group.isEnabled() && (isServerAdmin() || group.adminsInclude(Session.user()) ||
      (group.membersInclude(Session.user()) && group.membersCanAddMembers));
  },

  canAddGuests(group) {
    const user = Session.user();
    return !!user.emailVerified && !!group.subscription?.active &&
      (group.adminsInclude(user) || (group.membersCanAddGuests && group.membersInclude(user)));
  },

  canManageMembershipRequests(group) {
    return group.isEnabled() && (isServerAdmin() || (group.membersCanAddMembers && group.membersInclude(Session.user())) ||
      group.adminsInclude(Session.user()));
  },

  canNotify(group) {
    return group.isEnabled() && (group.adminsInclude(Session.user()) ||
      (group.membersCanAnnounce && group.membersInclude(Session.user())));
  },

  canAddSubgroup(group) {
    return group.isEnabled() && group.isParent() && (group.adminsInclude(Session.user()) ||
      (group.membersInclude(Session.user()) && group.membersCanCreateSubgroups));
  },

  canJoin(group) {
    if (!group.isEnabled() || !this.canShow(group) || !Session.user().emailVerified) { return false; }
    return (group.membershipGrantedUpon === 'request') || (!!group.parentId && group.parent().adminsInclude(Session.user()));
  },

  canRequestMembership(group) {
    return (group.membershipGrantedUpon === 'approval') && this.canShow(group);
  }
};
