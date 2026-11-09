import { vi } from 'vitest';
import { abilityContract, clientAttributes } from './support/ability_contract';

vi.mock('@/shared/services/session', async () => ({default: (await import('./support/ability_contract')).session}));
vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/i18n', () => ({I18n: {global: {t: key => key}}}));

import GroupAbility from '@/shared/abilities/group_ability';
import GroupModel from '@/shared/models/group_model';

abilityContract('group_abilities', {
  show: group => GroupAbility.canShow(group),
  see_private_content: group => GroupAbility.canSeePrivateContent(group),
  update: group => GroupAbility.canUpdate(group),
  destroy: group => GroupAbility.canDestroy(group),
  set_volume: group => GroupAbility.canSetVolume(group),
  add_members: group => GroupAbility.canAddMembers(group),
  add_guests: group => GroupAbility.canAddGuests(group),
  manage_membership_requests: group => GroupAbility.canManageMembershipRequests(group),
  notify: group => GroupAbility.canNotify(group),
  add_subgroup: group => GroupAbility.canAddSubgroup(group),
  join: group => GroupAbility.canJoin(group),
  request_membership: group => GroupAbility.canRequestMembership(group)
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
