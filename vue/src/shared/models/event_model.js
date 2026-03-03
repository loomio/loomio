import BaseModel from '@/shared/record_store/base_model';
import { I18n } from '@/i18n';
import {invokeMap, last} from 'lodash-es';
import Records from '@/shared/services/records';

export default class EventModel extends BaseModel {
  static singular = 'event';
  static plural = 'events';
  static indices = ['topicId', 'sequenceId', 'position', 'depth', 'parentId', 'positionKey'];
  static uniqueIndices = ['id'];

  constructor(...args) {
    super(...args);
    this.removeFromThread = this.removeFromThread.bind(this);
  }

  relationships() {
    this.belongsTo('parent', { from: 'events' });
    this.belongsTo('actor', { from: 'users' });
    this.hasMany('notifications');
  }

  defaultValues() {
    return {
      pinned: false,
      eventableId: null,
      eventableType: null,
      topicId: null,
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
      const topic = this.topic();
      const group = topic ? topic.group() : null;
      return this.actor().nameWithTitle(group);
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

  topic() {
    if (this.topicId) { return Records.topics.find(this.topicId); }
  }

  isUnread() {
    const topic = this.topic();
    if (topic) { return !topic.hasRead(this.sequenceId); }
    return false;
  }

  markAsRead() {
    const topic = this.topic();
    if (topic) { return topic.markAsRead(this.sequenceId); }
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
    const topic = this.topic();
    const d = topic && topic.discussion();
    return d && d.forkedEventIds && (d.forkedEventIds.includes(this.id) || this.parentIsForking());
  }

  parentIsForking() {
    return this.parent() && this.parent().isForking();
  }

  forkingDisabled() {
    return this.parentIsForking() || (this.parent() && (this.parent().kind === 'poll_created'));
  }
};
