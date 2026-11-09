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
  create: comment => CommentAbility.canCreate(comment.topic()),
  reply: comment => CommentAbility.canReply(comment),
  update: comment => CommentAbility.canUpdate(comment),
  discard: comment => CommentAbility.canDiscard(comment),
  undiscard: comment => CommentAbility.canUndiscard(comment),
  destroy: comment => CommentAbility.canDestroy(comment)
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
