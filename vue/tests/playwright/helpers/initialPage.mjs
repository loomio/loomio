// Main content and the group directory boot together. Navigation warm-up and
// the separate pinned-items request remain asynchronous.
export async function blockMainContentRequests(page, {group = false} = {}) {
  const requests = [];
  await page.route(/\/api\/v1\/(boot\/site|profile\/groups|topic_items|topics|polls|groups\/[^/?]+)(\?|$)/, route => {
    const url = new URL(route.request().url());
    const params = url.searchParams;
    const currentPath = new URL(page.url()).pathname;
    const topicListPage = group || ['/dashboard', '/inbox'].includes(currentPath);
    // Other pages warm the dashboard's unfiltered list after startup. Keep
    // intercepting the dashboard's own list and all filtered/group queries.
    const dashboardWarmup = currentPath !== '/dashboard' &&
      params.get('limit') === '30' && params.get('offset') === '0' && params.get('order') === 'id' &&
      [...params.keys()].every(key => ['limit', 'offset', 'order', 'exclude_types'].includes(key));
    const mainContent = url.pathname.endsWith('/boot/site') ||
      url.pathname.endsWith('/profile/groups') ||
      (group && /\/groups\/[^/]+$/.test(url.pathname)) ||
      (url.pathname.endsWith('/topic_items') && params.has('include_polls_not_closed')) ||
      (topicListPage && url.pathname.endsWith('/topics') && !params.has('last_activity_gte') && !dashboardWarmup) ||
      (url.pathname.endsWith('/polls') && params.get('status') !== 'vote');
    if (!mainContent) return route.continue();
    requests.push(url.toString());
    return route.abort();
  });
  return requests;
}
