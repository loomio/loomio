import BaseModel from '@/shared/record_store/base_model';
import { I18n } from '@/i18n';

export default class BookmarkModel extends BaseModel {
  static singular = 'bookmark';
  static plural = 'bookmarks';
  static indices = ['userId', 'bookmarkableId', 'bookmarkableType'];

  // title, url, authorName and pollType are provided by the server so a bookmark
  // is self-contained — the bookmarked record itself does not need to be loaded
  // to render the list.

  relationships() {
    this.belongsTo('user');
  }

  // A human label for the kind of item, eg. "Proposal" for a proposal poll,
  // otherwise the generic type name ("Discussion", "Comment", "Vote"…).
  typeLabel() {
    if (this.bookmarkableType === 'Poll' && this.pollType) {
      return I18n.global.t(`decision_tools_card.${this.pollType}_title`);
    }
    return I18n.global.t(`bookmarks.types.${this.bookmarkableType}`);
  }

  icon() {
    return {
      Discussion: 'mdi-forum-outline',
      Poll: 'mdi-poll',
      Comment: 'mdi-comment-outline',
      Stance: 'mdi-checkbox-marked-circle-outline',
      Outcome: 'mdi-bullhorn-outline'
    }[this.bookmarkableType];
  }
};
