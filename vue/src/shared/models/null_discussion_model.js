/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let NullDiscussionModel;
import {each} from 'lodash';
import Vue from 'vue';
import I18n from '@/i18n';
import NullGroupModel from '@/shared/models/null_group_model';

export default NullDiscussionModel = (function() {
  NullDiscussionModel = class NullDiscussionModel {
    static initClass() {
      this.singular = 'discussion';
      this.plural = 'discussions';
    }

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
  NullDiscussionModel.initClass();
  return NullDiscussionModel;
})();
