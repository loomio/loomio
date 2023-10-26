/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let EventModel;
import BaseModel from '@/shared/record_store/base_model';
import i18n from '@/i18n';
import {invokeMap, without} from 'lodash';

export default EventModel = (function() {
  EventModel = class EventModel extends BaseModel {
    constructor(...args) {
      super(...args);
      this.removeFromThread = this.removeFromThread.bind(this);
    }

    static initClass() {
      this.singular = 'event';
      this.plural = 'events';
      this.indices = ['discussionId', 'sequenceId', 'position', 'depth', 'parentId', 'positionKey'];
      this.uniqueIndices = ['id'];
    }

    relationships() {
      this.belongsTo('parent', {from: 'events'});
      this.belongsTo('actor', {from: 'users'});
      this.belongsTo('discussion');
      return this.hasMany('notifications');
    }

    defaultValues() {
      return {
        pinned: false,
        eventableId: null,
        eventableType: null,
        discussionId: null,
        sequenceId: null,
        positition: 0,
        showReplyForm: true
      };
    }

    parentOrSelf() {
      if (this.parentId) {
        return this.parent();
      } else {
        return this;
      }
    }

    isNested() { return this.depth > 1; }
    isSurface() { return this.depth === 1; }
    surfaceOrSelf() { if (this.isNested()) { return this.parent(); } else { return this; } }

    children() {
      return this.recordStore.events.find({parentId: this.id});
    }

    delete() {
      return this.deleted = true;
    }

    actorName() {
      if (this.actor()) {
        return this.actor().nameWithTitle(this.discussion().group());
      } else {
        return i18n.t('common.anonymous');
      }
    }

    actorUsername() {
      if (this.actor()) { return this.actor().username; }
    }

    model() {
      return this.recordStore[this.recordStore.eventTypeMap[this.eventableType]].find(this.eventableId);
    }

    isUnread() {
      return !this.discussion().hasRead(this.sequenceId);
    }

    markAsRead() {
      return this.discussion().markAsRead(this.sequenceId);
    }

    beforeRemove() {
      return invokeMap(this.notifications(), 'remove');
    }

    removeFromThread() {
      return this.remote.patchMember(this.id, 'remove_from_thread').then(() => this.remove());
    }

    pin(title) {
      return this.remote.patchMember(this.id, 'pin', {pinned_title: title});
    }

    fillPinnedTitle() {
      return this.pinnedTitle = this.suggestedTitle();
    }

    suggestedTitle() {
      const model = this.model();
      if (!model) { return ''; }

      if (model.title) {
        return model.title.replace(new RegExp(`<[^>]*>?`, 'gm'), '');
      } else {
        let el;
        const parser = new DOMParser();
        const doc = parser.parseFromString(model.statement || model.body, 'text/html');
        if ((el = doc.querySelector('h1,h2,h3'))) {
          return el.textContent;
        } else {
          return this.actor().name;
        }
      }
    }

    unpin() { return this.remote.patchMember(this.id, 'unpin'); }

    isForking() {
      return this.discussion() && (this.discussion().forkedEventIds.includes(this.id) || this.parentIsForking());
    }

    parentIsForking() {
      return this.parent() && this.parent().isForking();
    }

    forkingDisabled() {
      return this.parentIsForking() || (this.parent() && (this.parent().kind === 'poll_created'));
    }

    toggleForking() {
      if (this.isForking()) {
        return this.discussion().update({forkedEventIds: without(this.discussion().forkedEventIds, this.id)});
      } else {
        return this.discussion().forkedEventIds.push(this.id);
      }
    }

    next() {
      return this.recordStore.events.find({parentId: this.parentId, position: this.position + 1})[0];
    }

    previous() {
      return this.recordStore.events.find({parentId: this.parentId, position: this.position - 1})[0];
    }
  };
  EventModel.initClass();
  return EventModel;
})();
