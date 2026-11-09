import Records from '@/shared/services/records';

// Boot normally supplies groups and the viewer's memberships. The records
// interface shares any fallback request and allows explicit directory refreshes.
export function useCurrentUserGroups() {
  function loadGroups() {
    return Records.users.fetchGroups();
  }

  return { loadGroups };
}
