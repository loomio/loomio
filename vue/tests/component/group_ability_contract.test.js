import { vi } from 'vitest';
import { abilityContract, clientAttributes } from './support/ability_contract';

vi.mock('@/shared/services/session', async () => ({default: (await import('./support/ability_contract')).session}));
vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/i18n', () => ({I18n: {global: {t: key => key}}}));

import GroupAbility from '@/shared/abilities/group_ability';
import GroupModel from '@/shared/models/group_model';

abilityContract('group_abilities', {
  show: group => GroupAbility.show(group),
  see_private_content: group => GroupAbility.seePrivateContent(group),
  update: group => GroupAbility.update(group),
  destroy: group => GroupAbility.destroy(group),
  set_volume: group => GroupAbility.setVolume(group),
  add_members: group => GroupAbility.addMembers(group),
  add_guests: group => GroupAbility.addGuests(group),
  manage_membership_requests: group => GroupAbility.manageMembershipRequests(group),
  notify: group => GroupAbility.notify(group),
  add_subgroup: group => GroupAbility.addSubgroup(group),
  join: group => GroupAbility.join(group),
  request_membership: group => GroupAbility.requestMembership(group)
}, (testCase, roles) => {
  const {enabled, ...attributes} = testCase.group;
  const group = new GroupModel({...clientAttributes(attributes), enabled, subscription: {active: enabled}});
  const parent = new GroupModel({id: 1});
  parent.membersInclude = () => roles.parent_member;
  parent.adminsInclude = () => roles.parent_admin;
  group.membersInclude = () => roles.group_member;
  group.adminsInclude = () => roles.group_admin;
  group.parent = () => (group.parentId ? parent : undefined);
  group.parentOrSelf = () => (group.parentId ? parent : group);
  return group;
});
