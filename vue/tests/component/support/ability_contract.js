// Runs a client ability module against the server's answers recorded by a
// contract test in test/contracts. Generate the cases first with:
//   bin/rails test test/contracts
// Locally a missing contract skips its suite; in CI it fails.
import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { camelCase } from 'lodash-es';

const CONTRACT_DIR = resolve(__dirname, '../../../../tmp/contracts');

// Stands in for the Session service. Test files mock the service with it:
//   vi.mock('@/shared/services/session', async () =>
//     ({default: (await import('./support/ability_contract')).session}));
export const session = {
  current: null,
  user() { return this.current; },
  isSignedIn() { return !!this.current?.signedIn; },
  get userId() { return this.current?.id; }
};

export function clientAttributes(attributes = {}) {
  return Object.fromEntries(Object.entries(attributes).map(([key, value]) =>
    [camelCase(key), key.endsWith('_at') && value ? new Date(value) : value]
  ));
}

function userFor(roles) {
  return {
    id: roles.user_id,
    signedIn: roles.signed_in,
    emailVerified: roles.email_verified,
    isAdmin: roles.server_admin
  };
}

// Calls build(testCase, roles) for each case to get the client subject, then
// compares each action in `actions` with the server's answer.
export function abilityContract(name, actions, build) {
  const path = resolve(CONTRACT_DIR, `${name}.json`);
  const generated = existsSync(path);
  const contract = generated ? JSON.parse(readFileSync(path, 'utf8')) : {cases: []};

  it.runIf(process.env.CI)(`has generated ${name} cases`, () => {
    expect(generated).toBe(true);
  });

  describe.runIf(generated)(`${name} match the server`, () => {
    beforeAll(() => {
      vi.useFakeTimers();
      vi.setSystemTime(new Date(contract.contract_time));
    });

    afterAll(() => vi.useRealTimers());

    it('covers every recorded server action', () => {
      const recorded = new Set(contract.cases.flatMap(testCase => Object.keys(testCase.expected)));
      expect(Object.keys(actions).sort()).toEqual([...recorded].sort());
    });

    it.each(contract.cases.map(testCase => [testCase.name, testCase]))('%s', (_name, testCase) => {
      session.current = userFor(testCase.roles);
      const subject = build(testCase, testCase.roles);
      const differences = Object.keys(testCase.expected).flatMap(action => {
        const client = !!actions[action](subject);
        const server = testCase.expected[action];
        return client === server ? [] : [`${action}: server ${server}, client ${client}`];
      });
      if (differences.length) { throw new Error(differences.join('; ')); }
    });
  });
}
