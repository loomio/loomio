import BaseModel        from '@/shared/record_store/base_model';
import AppConfig        from '@/shared/services/app_config';
import Session          from '@/shared/services/session';
import { compact, pick }         from 'lodash-es';

export default class DiscussionTemplateModel extends BaseModel {
  static singular = 'discussionTemplate';
  static plural = 'discussionTemplates';
  static uniqueIndices = ['id', 'key'];
  static indices = ['groupId'];

  defaultValues() {
    return {
      description: null,
      descriptionFormat: 'html',
      processIntroduction: null,
      processIntroductionFormat: 'html',
      title: null,
      tags: [],
      files: [],
      imageFiles: [],
      attachments: [],
      linkPreviews: [],
      maxDepth: 3,
      newestFirst: false,
      pollTemplateKeysOrIds: [],
      recipientAudience: null
    };
  }
  
  relationships() {
    this.belongsTo('author', {from: 'users'});
    return this.belongsTo('group');
  }

  buildDiscussion() {
    const discussion = this.recordStore.discussions.build();

    const attrs = pick(this, Object.keys(this.defaultValues()));
    attrs.discussionTemplateId = this.id;
    attrs.discussionTemplateKey = this.key;
    attrs.authorId = Session.user().id;

    discussion.update(attrs);

    return discussion;
  }

  pollTemplates() {
    return compact(this.pollTemplateKeysOrIds.map(keyOrId => {
      return this.recordStore.pollTemplates.find(keyOrId);
    })
    );
  }

  pollTemplateIds() {
    return this.pollTemplateKeysOrIds.filter(keyOrId => typeof(keyOrId) === 'number');
  }

  pollTemplateKeys() {
    return this.pollTemplateKeysOrIds.filter(keyOrId => typeof(keyOrId) === 'string');
  }
};

