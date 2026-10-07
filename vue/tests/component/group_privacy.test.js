import {describe, expect, it, vi} from 'vitest';

vi.mock('@/i18n', () => ({I18n: {global: {t: key => key}}}));
vi.mock('@/shared/services/records', () => ({default: {}}));

import {groupPrivacy, groupPrivacyOptions, groupPrivacyStatement, groupMembershipGrantedUpon} from '@/shared/helpers/helptext';
import GroupModel from '@/shared/models/group_model';
import NullGroupModel from '@/shared/models/null_group_model';

describe('subgroup privacy explanations', () => {
  it.each([
    ['open', ['open', 'closed', 'parent_members', 'secret']],
    ['closed', ['open', 'closed', 'parent_members', 'secret']],
    ['secret', ['parent_members', 'secret']],
    ['parent_members', ['parent_members', 'secret']]
  ])('limits subgroup privacy under a %s parent', (privacy, expected) => {
    const group = {parentId: 1, parent: () => ({groupPrivacy: privacy})};
    expect(groupPrivacyOptions(group)).toEqual(expected);
  });

  it('does not offer parent visibility for a root group', () => {
    expect(groupPrivacyOptions({parentId: null})).toEqual(['open', 'closed', 'secret']);
  });

  it.each([
    ['open', 'subgroup_name_and_content_are_public', 'public_on_web'],
    ['closed', 'subgroup_name_is_public_and_threads_are_private', 'public_on_web'],
    ['parent_members', 'subgroup_is_visible_to_parent_members', 'private_to_parent_members'],
    ['secret', 'subgroup_privacy_is_secret_description', 'private_to_group']
  ])('describes %s using the subgroup audience', (privacy, description, statement) => {
    const group = {isParent: () => false, groupPrivacy: privacy};
    expect(groupPrivacy(group)).toBe(`group_form.${description}`);
    expect(groupPrivacyStatement(group)).toBe(`group_form.privacy_statement.${statement}`);
  });

  it('labels immediate joining for the selected visibility without adding a membership mode', () => {
    const group = {privacyIsParentMembers: () => true};
    expect(groupMembershipGrantedUpon(group, 'request')).toBe('group_form.membership_granted_upon_request_parent_members');
    expect(groupMembershipGrantedUpon(group, 'approval')).toBe('group_form.membership_granted_upon_approval_parent_members');
    expect(groupMembershipGrantedUpon({privacyIsParentMembers: () => false}, 'request')).toBe('group_form.membership_granted_upon_request');
  });

  it('exposes parent visibility on real groups and returns false on the null group', () => {
    expect(GroupModel.prototype.privacyIsParentMembers.call({groupPrivacy: 'parent_members'})).toBe(true);
    expect(GroupModel.prototype.privacyIsParentMembers.call({groupPrivacy: 'closed'})).toBe(false);
    expect(new NullGroupModel().privacyIsParentMembers()).toBe(false);
  });
});
