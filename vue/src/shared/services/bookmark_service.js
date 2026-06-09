import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash   from '@/shared/services/flash';
import { useBookmarks } from '@/composables/useBookmarks';
import { capitalize } from 'lodash-es';

const { loadBookmarks } = useBookmarks();

export default new class BookmarkService {
  // The polymorphic type stored on the bookmark, e.g. 'Comment', 'Poll'.
  typeFor(model) {
    return capitalize(model.constructor.singular);
  }

  bookmarkFor(model) {
    if (!model || !model.id) { return null; }
    return Records.bookmarks.find({
      userId: Session.userId,
      bookmarkableType: this.typeFor(model),
      bookmarkableId: model.id
    })[0];
  }

  // Returns the save/remove bookmark menu actions for a bookmarkable model.
  // Only one is performable at a time, depending on whether a bookmark exists.
  actions(model) {
    // Ensure the user's bookmarks are loaded once per session so the toggle
    // reflects the correct save/remove state.
    loadBookmarks();

    const service = this;
    return {
      save_bookmark: {
        icon: 'mdi-bookmark-outline',
        name: 'action_dock.save_bookmark',
        menu: true,
        canPerform() { return Session.isSignedIn() && !service.bookmarkFor(model); },
        perform() {
          return Records.bookmarks.build({
            userId: Session.userId,
            bookmarkableType: service.typeFor(model),
            bookmarkableId: model.id
          }).save().then(() => Flash.success('bookmarks.saved'));
        }
      },

      remove_bookmark: {
        icon: 'mdi-bookmark',
        name: 'action_dock.remove_bookmark',
        menu: true,
        canPerform() { return Session.isSignedIn() && !!service.bookmarkFor(model); },
        perform() {
          const bookmark = service.bookmarkFor(model);
          if (bookmark) {
            return bookmark.destroy().then(() => Flash.success('bookmarks.removed'));
          }
        }
      }
    };
  }
};
