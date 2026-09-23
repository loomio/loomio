export function subscriptionUpgradeUrl({ baseUrl, loomioSubscriptions, groupId }) {
  return subscriptionUrl(baseUrl, loomioSubscriptions ? 'subscriptions' : 'upgrade', groupId);
}

export function subscriptionManagementUrl({ baseUrl, groupId }) {
  return `${baseUrl}subscriptions/manage/${groupId}`;
}

function subscriptionUrl(baseUrl, path, groupId) {
  const groupPath = groupId ? `/${groupId}` : '';
  return `${baseUrl}${path}${groupPath}`;
}
