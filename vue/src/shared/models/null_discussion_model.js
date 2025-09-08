import {each} from 'lodash-es';
import { I18n } from '@/i18n';
import NullGroupModel from '@/shared/models/null_group_model';

export default class NullDiscussionModel {
  static singular = 'discussion';
  static plural = 'discussions';

  constructor() {
    const defaults = {
      id: null,
      title: 'No thread',
      description: '',
      descriptionFormat: 'html',
      key: null,
      private: true,
      lastItemAt: null,
      forkedEventIds: [],
      ranges: [],
      readRanges: [],
      isForking: false,
      newestFirst: false,
      files: null,
      imageFiles: null,
      attachments: [],
      linkPreviews: [],
      recipientMessage: null,
      recipientAudience: null,
      recipientUserIds: [],
      recipientChatbotIds: [],
      recipientEmails: [],
      notifyRecipients: true,
      groupId: null
    };

    each(defaults, (value, key) => {
      this[key] = value;
      return true;
    });
  }

  polls() { return []; }
  discussion() { return this; }
  group() { return new NullGroupModel(); }
  markAsRead() { return false; }
};
