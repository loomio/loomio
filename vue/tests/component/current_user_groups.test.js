import { beforeEach, describe, expect, it, vi } from 'vitest';
import AppConfig from '@/shared/services/app_config';
import UserRecordsInterface from '@/shared/interfaces/user_records_interface';

vi.mock('@/shared/models/user_model', () => ({default: class {}}));
vi.mock('@/shared/models/anonymous_user_model', () => ({default: class {}}));

let users;
beforeEach(() => {
  AppConfig.groupsLoaded = false;
  users = Object.create(UserRecordsInterface.prototype);
  users.fetch = vi.fn().mockResolvedValue({groups: [], memberships: []});
});

describe('current user groups', () => {
  it('uses the complete directory provided by boot', async () => {
    AppConfig.groupsLoaded = true;
    await users.fetchGroups();
    expect(users.fetch).not.toHaveBeenCalled();
  });

  it('shares an initial request and supports a later explicit refresh', async () => {
    let finish;
    users.fetch.mockImplementationOnce(() => new Promise(resolve => { finish = resolve; }));
    const initial = users.fetchGroups();
    expect(users.fetchGroups()).toBe(initial);
    finish({groups: [{id: 10}], memberships: [{id: 20}]});
    await initial;
    expect(AppConfig.groupsLoaded).toBe(true);
    await users.fetchGroups();
    expect(users.fetch).toHaveBeenCalledTimes(1);
    const refresh = users.refreshGroups();
    expect(users.refreshGroups()).toBe(refresh);
    await refresh;
    expect(users.fetch).toHaveBeenCalledTimes(2);
  });

  it('allows retrying a failed initial request', async () => {
    users.fetch.mockRejectedValueOnce(new TypeError('Offline'));
    await expect(users.fetchGroups()).rejects.toThrow('Offline');
    expect(AppConfig.groupsLoaded).toBe(false);
    await users.fetchGroups();
    expect(users.fetch).toHaveBeenCalledTimes(2);
    expect(AppConfig.groupsLoaded).toBe(true);
  });
});
