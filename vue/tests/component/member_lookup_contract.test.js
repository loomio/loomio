import { vi } from 'vitest';
import { abilityContract } from './support/ability_contract';

vi.mock('@/shared/services/session', async () => ({default: (await import('./support/ability_contract')).session}));

import Records from '@/shared/services/records';

// Imports what the server sends this user into the real record store, then
// asks the client models who counts as an admin or member.
abilityContract('member_lookups', {
  group_admin: ({topic, user}) => topic.group().adminsInclude(user),
  group_member: ({topic, user}) => topic.group().membersInclude(user),
  topic_admin: ({topic, user}) => topic.adminsInclude(user),
  topic_member: ({topic, user}) => topic.membersInclude(user),
  poll_admin: ({poll, user}) => poll.adminsInclude(user),
  poll_member: ({poll, user}) => poll.membersInclude(user)
}, (testCase, roles) => {
  Records.collectionNames.forEach(name => {
    const collection = Records[name].collection;
    collection.find().forEach(doc => collection.remove(doc));
  });
  Records.importJSON(testCase.payload);
  return {
    user: Records.users.find(roles.user_id),
    topic: Records.topics.find(testCase.topic_id),
    poll: Records.polls.find(testCase.poll_id)
  };
});
