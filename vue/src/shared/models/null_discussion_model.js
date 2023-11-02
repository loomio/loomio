import {each} from 'lodash';
import Vue from 'vue';
import I18n from '@/i18n';
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
      files: [],
      imageFiles: [],
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
      Vue.set(this, key, value);
      return true;
    });
  }

  polls() { return []; }
  discussion() { return this; }
  group() { return new NullGroupModel(); }
  markAsRead() { return false; }
};
