import Session from '@/shared/services/session';

// Mirrors the server's TagService.can_create_tag? using the raw state the
// client receives. test/contracts/tag_ability_contract_test.rb checks it.
export default {
  canCreate(group) {
    const user = Session.user();
    return group.parentOrSelf().adminsInclude(user) ||
      group.adminsInclude(user) ||
      !!(group.membersCanCreateTags && group.membersInclude(user));
  }
};
