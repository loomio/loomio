import { vi } from 'vitest';
import { abilityContract, clientAttributes } from './support/ability_contract';

const replies = vi.hoisted(() => ({count: 0}));

vi.mock('@/shared/services/session', async () => ({default: (await import('./support/ability_contract')).session}));
vi.mock('@/shared/services/records', () => ({
  default: {comments: {find: () => Array.from({length: replies.count})}}
}));
vi.mock('@/i18n', () => ({I18n: {global: {t: key => key}}}));

import CommentAbility from '@/shared/abilities/comment_ability';
import NullGroupModel from '@/shared/models/null_group_model';

abilityContract('comment_abilities', {
  create: comment => CommentAbility.create(comment.topic()),
  reply: comment => CommentAbility.reply(comment),
  update: comment => CommentAbility.update(comment),
  discard: comment => CommentAbility.discard(comment),
  undiscard: comment => CommentAbility.undiscard(comment),
  destroy: comment => CommentAbility.destroy(comment)
}, (testCase, roles) => {
  replies.count = testCase.reply_count;
  const group = Object.keys(testCase.group).length
    ? {isEnabled: () => true, ...clientAttributes(testCase.group)}
    : new NullGroupModel();
  const topic = {
    ...clientAttributes(testCase.topic),
    group: () => group,
    adminsInclude: () => roles.topic_admin,
    membersInclude: () => roles.topic_member
  };
  return {
    ...clientAttributes(testCase.comment),
    topic: () => topic,
    group: () => group,
    authorIs: () => roles.author
  };
});
