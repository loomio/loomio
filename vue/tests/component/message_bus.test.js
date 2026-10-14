import {afterEach, beforeEach, describe, expect, it, vi} from 'vitest';

const mocks = vi.hoisted(() => ({
  subscriptions: [], disconnect: vi.fn(), importJSON: vi.fn(),
  revoke: vi.fn(), restore: vi.fn(), emit: vi.fn()
}));
vi.mock('@rails/actioncable', () => ({createConsumer: () => ({
  disconnect: mocks.disconnect,
  subscriptions: {create: (channel, callbacks) => mocks.subscriptions.push({channel, callbacks})}
})}));
vi.mock('@/shared/services/records', () => ({default: {
  importJSON: mocks.importJSON,
  memberships: {revokeGroupAccess: mocks.revoke, restoreGroupAccess: mocks.restore}
}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: mocks.emit}}));

import {initLiveUpdate, closeLiveUpdate} from '@/shared/helpers/message_bus';

describe('realtime membership access', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.subscriptions.length = 0;
    mocks.restore.mockResolvedValue(undefined);
    initLiveUpdate();
  });
  afterEach(closeLiveUpdate);

  it('invalidates group access on a user-channel revocation', () => {
    mocks.subscriptions[0].callbacks.received({membership_access: {group_ids: [10, 11], revoked: true}});
    expect(mocks.revoke).toHaveBeenCalledWith([10, 11]);
    expect(mocks.restore).not.toHaveBeenCalled();
  });

  it('refreshes restored memberships and voting state', () => {
    mocks.subscriptions[0].callbacks.received({membership_access: {group_ids: [10], revoked: false}});
    expect(mocks.restore).toHaveBeenCalledWith([10]);
    expect(mocks.revoke).not.toHaveBeenCalled();
  });

  it('continues to import ordinary records and deliver system notices', () => {
    mocks.subscriptions[0].callbacks.received({records: {polls: [{id: 1}]}});
    mocks.subscriptions[1].callbacks.received({notice: 'Maintenance'});
    expect(mocks.importJSON).toHaveBeenCalledWith({polls: [{id: 1}]});
    expect(mocks.emit).toHaveBeenCalledWith('systemNotice', {notice: 'Maintenance'});
  });
});
