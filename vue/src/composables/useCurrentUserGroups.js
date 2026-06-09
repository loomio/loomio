import Records from '@/shared/services/records';

// Fetches the current user's groups exactly once for the whole frontend. The
// group serializer side-loads the current user's membership for each group, so
// this also ensures the user's memberships are loaded. Always returns the same
// promise, so any component can await it to be sure the groups are in the
// record store before reading them.
let groupsPromise = null;

export function useCurrentUserGroups() {
  function loadGroups() {
    groupsPromise ||= Records.users.fetchGroups();
    return groupsPromise;
  }

  return { loadGroups };
}
