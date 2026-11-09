// Checks client poll abilities against the server's answers recorded by
// test/contracts/poll_ability_contract_test.rb. Each case gives the poll fields
// the client receives, so AbilityService must reach the server's answer from
// that raw state alone, through PollAbility. Generate the cases first with:
//   bin/rails test test/contracts/poll_ability_contract_test.rb
import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { camelCase } from 'lodash-es';

const CONTRACT_PATH = resolve(__dirname, '../../../tmp/contracts/poll_abilities.json');
const contractGenerated = existsSync(CONTRACT_PATH);
const contract = contractGenerated ? JSON.parse(readFileSync(CONTRACT_PATH, 'utf8')) : {cases: []};

vi.mock('@/shared/services/session', () => ({default: {user: () => ({id: 1})}}));
vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/i18n', () => ({I18n: {}}));

import AbilityService from '@/shared/services/ability_service';
import PollAbility from '@/shared/abilities/poll_ability';
import OutcomeAbility from '@/shared/abilities/outcome_ability';
import PollModel from '@/shared/models/poll_model';

const CLIENT_ABILITIES = {
  update: poll => PollAbility.update(poll),
  destroy: poll => PollAbility.destroy(poll),
  close: poll => PollAbility.close(poll),
  reopen: poll => PollAbility.reopen(poll),
  export: poll => PollAbility.export(poll),
  create_outcome: poll => OutcomeAbility.create(poll)
};

const clientAttributes = attributes => Object.fromEntries(Object.entries(attributes).map(([key, value]) =>
  [camelCase(key), key.endsWith('_at') && value ? new Date(value) : value]
));

function buildPoll(testCase) {
  const poll = new PollModel(clientAttributes(testCase.poll));
  const topic = clientAttributes(testCase.topic);
  const group = {isEnabled: () => true, ...clientAttributes(testCase.group)};
  poll.topic = () => topic;
  poll.group = () => group;
  poll.adminsInclude = () => testCase.role === 'admin';
  poll.membersInclude = () => testCase.role !== 'visitor';
  return poll;
}

// CI generates the cases before this suite, so a missing file must fail there.
it.runIf(process.env.CI)('has generated server cases to check against', () => {
  expect(contractGenerated).toBe(true);
});

describe.runIf(contractGenerated)('poll abilities match the server contract', () => {
  beforeAll(() => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date(contract.contract_time));
  });

  afterAll(() => vi.useRealTimers());

  it('covers every recorded server action', () => {
    expect(Object.keys(contract.cases[0].expected).sort()).toEqual(Object.keys(CLIENT_ABILITIES).sort());
  });

  it.each(contract.cases.map(testCase => [testCase.name, testCase]))('%s', (_name, testCase) => {
    const poll = buildPoll(testCase);
    const actual = Object.fromEntries(Object.keys(CLIENT_ABILITIES).map(action =>
      [action, !!CLIENT_ABILITIES[action](poll)]
    ));
    expect(actual).toEqual(testCase.expected);
  });
});
