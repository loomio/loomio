import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { beforeAll, describe, expect, it, vi } from 'vitest';
import { abilityContract, session } from './support/ability_contract';

vi.mock('@/shared/services/session', async () => ({default: (await import('./support/ability_contract')).session}));

import AppConfig from '@/shared/services/app_config';
import Records from '@/shared/services/records';
import GroupService from '@/shared/services/group_service';

function importGroup(testCase) {
  Records.collectionNames.forEach(name => {
    const collection = Records[name].collection;
    collection.find().forEach(doc => collection.remove(doc));
  });
  Records.importJSON(testCase.payload);
  return Records.groups.find(testCase.group_id);
}

// Imports the group payload each viewer receives and checks that the client
// reaches the server's answer from the raw subscription state.
abilityContract('group_enabled', {
  enabled: group => group.isEnabled()
}, importGroup);

// The group page menu checks every action for each viewer, including visitors
// without a membership.
const CONTRACT_PATH = resolve(__dirname, '../../../tmp/contracts/group_enabled.json');
const cases = existsSync(CONTRACT_PATH) ? JSON.parse(readFileSync(CONTRACT_PATH, 'utf8')).cases : [];

describe.runIf(cases.length)('group actions for each viewer', () => {
  beforeAll(() => {
    Object.assign(AppConfig, {features: {app: {}}, inlineTranslation: {isAvailable: false}, theme: {}});
  });

  it.each(cases.map(testCase => [testCase.name, testCase]))('%s', (_name, testCase) => {
    const roles = testCase.roles;
    session.current = {id: roles.user_id, signedIn: roles.signed_in, emailVerified: roles.email_verified, isAdmin: roles.server_admin};
    const group = importGroup(testCase);
    for (const action of Object.values(GroupService.actions(group))) {
      expect(() => action.canPerform()).not.toThrow();
    }
  });
});
