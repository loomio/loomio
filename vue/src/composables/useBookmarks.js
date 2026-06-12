import Records from '@/shared/services/records';

// Fetches the current user's bookmarks exactly once for the whole frontend.
// Bookmarks are private to the user and self-contained (each carries its own
// title and url), so a single fetch is enough to know what is bookmarked and to
// render the bookmarks list. Always returns the same promise, so any component
// can await it to be sure the bookmarks are in the record store before reading
// them.
let bookmarksPromise = null;

export function useBookmarks() {
  function loadBookmarks() {
    bookmarksPromise ||= Records.bookmarks.fetch({});
    return bookmarksPromise;
  }

  return { loadBookmarks };
}
