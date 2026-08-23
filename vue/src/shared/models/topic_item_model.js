import BaseModel from '@/shared/record_store/base_model';
import { I18n } from '@/i18n';
import Records from '@/shared/services/records';

export default class TopicItemModel extends BaseModel {
  static singular = 'topicItem';
  static plural = 'topicItems';
  static indices = ['topicId', 'sequenceId', 'position', 'depth', 'parentId', 'positionKey'];
  static uniqueIndices = ['id'];

  constructor(...args) {
    super(...args);
  }

  relationships() {
    this.belongsTo('parent', { from: 'topicItems' });
    this.belongsTo('actor', { from: 'users' });
  }

  defaultValues() {
    return {
      pinned: false,
      itemableId: null,
      itemableType: null,
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
    return Records.topicItems.find({ parentId: this.id });
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
    return Records[BaseModel.itemTypeMap[this.itemableType]].find(this.itemableId);
  }

  isPollTopicItem() {
    return ['Poll', 'Outcome', 'Stance'].includes(this.itemableType);
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

  pin(title) {
    return Records.topicItems.remote.patchMember(this.id, 'pin', { pinned_title: title });
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

  unpin() { return Records.topicItems.remote.patchMember(this.id, 'unpin'); }

  isSelectedForMove() {
    const topic = this.topic();
    return topic && topic.selectedTopicItemIds && (topic.selectedTopicItemIds.includes(this.id) || this.parentIsSelectedForMove());
  }

  parentIsSelectedForMove() {
    return this.parent() && this.parent().isSelectedForMove();
  }

  moveSelectionDisabled() {
    return this.parentIsSelectedForMove() || (this.parent() && (this.parent().kind === 'poll_created'));
  }
};
