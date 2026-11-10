import { vi } from 'vitest';
import { abilityContract } from './support/ability_contract';

vi.mock('@/shared/services/session', async () => ({default: (await import('./support/ability_contract')).session}));

import Records from '@/shared/services/records';

// Imports the group payload each viewer receives and checks that the client
// reaches the server's answer from the raw subscription state.
abilityContract('group_enabled', {
  enabled: group => group.isEnabled()
}, testCase => {
  Records.collectionNames.forEach(name => {
    const collection = Records[name].collection;
    collection.find().forEach(doc => collection.remove(doc));
  });
  Records.importJSON(testCase.payload);
  return Records.groups.find(testCase.group_id);
});
