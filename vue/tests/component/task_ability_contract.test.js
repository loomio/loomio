import { vi } from 'vitest';
import { abilityContract } from './support/ability_contract';

const facts = vi.hoisted(() => ({recordUpdate: false}));

vi.mock('@/shared/services/session', async () => ({default: (await import('./support/ability_contract')).session}));
// Each record's own contract checks its update rule, so this contract supplies
// the server's answer and checks how TaskAbility combines it.
vi.mock('@/shared/abilities/discussion_ability', () => ({default: {canUpdate: () => facts.recordUpdate}}));
vi.mock('@/shared/abilities/comment_ability', () => ({default: {canUpdate: () => facts.recordUpdate}}));

import TaskAbility from '@/shared/abilities/task_ability';

abilityContract('task_abilities', {
  update: ({record, task}) => TaskAbility.canUpdate(record, task)
}, testCase => {
  facts.recordUpdate = testCase.record_update;
  return {
    record: {
      isA: kind => kind === testCase.kind,
      group: () => ({isEnabled: () => testCase.group_enabled})
    },
    task: {authorId: testCase.task.author_id, mentioned: testCase.task.mentioned}
  };
});
