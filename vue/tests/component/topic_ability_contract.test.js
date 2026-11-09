import { vi } from 'vitest';
import { abilityContract, clientAttributes } from './support/ability_contract';

vi.mock('@/shared/services/session', async () => ({default: (await import('./support/ability_contract')).session}));
vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/i18n', () => ({I18n: {global: {t: key => key}}}));

import TopicAbility from '@/shared/abilities/topic_ability';
import NullGroupModel from '@/shared/models/null_group_model';

abilityContract('topic_abilities', {
  update: topic => TopicAbility.canUpdate(topic),
  attach_files: topic => TopicAbility.canAttachFiles(topic),
  announce: topic => TopicAbility.canAnnounce(topic),
  add_guests: topic => TopicAbility.canAddGuests(topic),
  move: topic => TopicAbility.canMove(topic),
  move_comments: topic => TopicAbility.canMoveComments(topic),
  update_tags: topic => TopicAbility.canUpdateTags(topic)
}, (testCase, roles) => {
  let group;
  if (Object.keys(testCase.group).length) {
    const {allow_guests, ...settings} = testCase.group;
    group = {
      ...clientAttributes(settings),
      subscription: {allow_guests},
      isEnabled: () => true,
      parentOrSelf() { return this; },
      adminsInclude: () => roles.group_admin,
      membersInclude: () => roles.group_member
    };
  } else {
    group = new NullGroupModel();
  }
  return {
    ...clientAttributes(testCase.topic),
    group: () => group,
    topicable: () => clientAttributes(testCase.topicable),
    adminsInclude: () => roles.topic_admin,
    membersInclude: () => roles.topic_member
  };
});
