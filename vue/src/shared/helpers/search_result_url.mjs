function stub(name) {
  return String(name ?? '').replace(/[^a-z0-9\-_]+/gi, '-').replace(/-+/g, '-').toLowerCase();
}

export function urlForSearchResult(result) {
  switch (result.searchable_type) {
    case 'Discussion':
      return `/d/${result.discussion_key}/${stub(result.discussion_title)}`;
    case 'Comment':
      return `/d/${result.discussion_key}/comment/${result.searchable_id}`;
    case 'Poll': case 'Outcome': case 'Stance':
      if (result.discussion_key && result.discussion_title != null && result.sequence_id != null) {
        return `/d/${result.discussion_key}/${stub(result.discussion_title)}/${result.sequence_id}`;
      }
      return `/p/${result.poll_key}/${stub(result.poll_title)}`;
    default:
      return '/notdefined';
  }
}
