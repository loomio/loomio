import Session from '@/shared/services/session';

// Mirrors the server's Ability::Membership using the raw state the client
// receives. test/contracts/membership_ability_contract_test.rb checks these rules.
export default {
  update(membership) {
    return membership.group().isEnabled() &&
      ((membership.userId === Session.userId) || membership.group().adminsInclude(Session.user()));
  },

  resend(membership) {
    return membership.group().isEnabled() && !membership.acceptedAt && membership.group().adminsInclude(Session.user());
  },

  // Members can leave, admins can remove anyone, and inviters can cancel a
  // pending invitation they sent.
  destroy(membership) {
    return !!Session.user().isAdmin || (membership.userId === Session.userId) ||
      membership.group().adminsInclude(Session.user()) ||
      (membership.inviterId === Session.userId && !membership.acceptedAt);
  }
};
