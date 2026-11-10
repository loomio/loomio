import { vi } from 'vitest';
import { abilityContract, clientAttributes } from './support/ability_contract';

vi.mock('@/shared/services/session', async () => ({default: (await import('./support/ability_contract')).session}));
vi.mock('@/shared/services/records', () => ({default: {}}));
vi.mock('@/i18n', () => ({I18n: {global: {t: key => key}}}));

import PollAbility from '@/shared/abilities/poll_ability';
import OutcomeAbility from '@/shared/abilities/outcome_ability';
import PollModel from '@/shared/models/poll_model';
import NullGroupModel from '@/shared/models/null_group_model';

abilityContract('poll_audience_abilities', {
  create: poll => PollAbility.canCreate(poll.topic()),
  announce: poll => PollAbility.canAnnounce(poll),
  remind: poll => PollAbility.canRemind(poll),
  add_voters: poll => PollAbility.canAddVoters(poll),
  add_guests: poll => PollAbility.canAddGuests(poll),
  view_anonymous_voters: poll => PollAbility.canViewAnonymousVoters(poll),
  create_outcome: poll => OutcomeAbility.canCreate(poll)
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
  const topic = {
    ...clientAttributes(testCase.topic),
    group: () => group,
    adminsInclude: () => roles.topic_admin,
    membersInclude: () => roles.topic_member
  };
  const poll = new PollModel(clientAttributes(testCase.poll));
  poll.group = () => group;
  poll.topic = () => topic;
  poll.adminsInclude = () => roles.poll_admin;
  poll.membersInclude = () => roles.poll_member;
  poll.myStance = () => undefined;
  return poll;
});
