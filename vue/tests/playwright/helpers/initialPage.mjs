// Block only the requests needed for main content. Navigation and notification
// requests remain asynchronous, including the separate pinned-items request.
export async function blockMainContentRequests(page, {group = false} = {}) {
  const requests = [];
  await page.route(/\/api\/v1\/(boot\/site|topic_items|topics|polls|groups\/[^/?]+)(\?|$)/, route => {
    const url = new URL(route.request().url());
    const params = url.searchParams;
    const mainContent = url.pathname.endsWith('/boot/site') ||
      (group && /\/groups\/[^/]+$/.test(url.pathname)) ||
      (url.pathname.endsWith('/topic_items') && params.has('include_polls_not_closed')) ||
      (url.pathname.endsWith('/topics') && !params.has('last_activity_gte')) ||
      (url.pathname.endsWith('/polls') && params.get('exclude_types') === 'reaction');
    if (!mainContent) return route.continue();
    requests.push(url.toString());
    return route.abort();
  });
  return requests;
}
