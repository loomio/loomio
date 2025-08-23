import BaseModel from '@/shared/record_store/base_model';
import { I18n } from '@/i18n';
import {invokeMap, last} from 'lodash-es';
import Records from '@/shared/services/records';

export default class EventModel extends BaseModel {
  static singular = 'event';
  static plural = 'events';
  static indices = ['discussionId', 'sequenceId', 'position', 'depth', 'parentId', 'positionKey'];
  static uniqueIndices = ['id'];

  constructor(...args) {
    super(...args);
    this.removeFromThread = this.removeFromThread.bind(this);
  }

  relationships() {
    this.belongsTo('parent', { from: 'events' });
    this.belongsTo('actor', { from: 'users' });
    this.belongsTo('discussion');
    this.hasMany('notifications');
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
    return Records.events.find({ parentId: this.id });
  }

  delete() {
    return this.deleted = true;
  }

  actorName() {
    if (this.actor()) {
      return this.actor().nameWithTitle(this.discussion().group());
    } else {
      return I18n.global.t('common.anonymous');
    }
  }

  actorUsername() {
    if (this.actor()) { return this.actor().username; }
  }

  model() {
    return Records[BaseModel.eventTypeMap[this.eventableType]].find(this.eventableId);
  }

  isPollEvent() {
    return ['Poll', 'Outcome', 'Stance'].includes(this.eventableType);
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
    return Records.events.remote.patchMember(this.id, 'remove_from_thread').then(() => this.remove());
  }

  pin(title) {
    return Records.events.remote.patchMember(this.id, 'pin', { pinned_title: title });
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

  unpin() { return Records.events.remote.patchMember(this.id, 'unpin'); }

  isForking() {
    return this.discussion() && (this.discussion().forkedEventIds.includes(this.id) || this.parentIsForking());
  }

  parentIsForking() {
    return this.parent() && this.parent().isForking();
  }

  forkingDisabled() {
    return this.parentIsForking() || (this.parent() && (this.parent().kind === 'poll_created'));
  }

  next() {
    return Records.events.find({ parentId: this.parentId, position: this.position + 1 })[0];
  }

  previous() {
    return Records.events.find({ parentId: this.parentId, position: this.position - 1 })[0];
  }

  nextSiblingPositionKey() {
    // skipping any child positions
    let strs = this.positionKey.split("-")
    let num = this.position + 1
    strs[strs.length - 1] = "0".repeat(5 - String(num).length).concat(num)
    return strs.join("-")
  }

  positionKeyMinus(count) {
    let parts = this.positionKey.split('-');
    const lastVal = parseInt(parts.pop()) - count;
    if (lastVal > 0) { parts.push("0".repeat(5 - String(lastVal).length).concat(lastVal)) }
    return parts.join('-');
  }

  positionKeyParent() {
    return this.positionKey.split('-').slice(0, -1).join('-');
  }
};
