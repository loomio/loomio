import BaseModel        from '@/shared/record_store/base_model';
import AppConfig        from '@/shared/services/app_config';
import Session          from '@/shared/services/session';
import { pick }            from 'lodash-es';
import I18n             from '@/i18n';
import { startOfHour, addDays } from 'date-fns';

export default class PollTemplateModel extends BaseModel {
  static singular = 'pollTemplate';
  static plural = 'pollTemplates';
  static uniqueIndices = ['id', 'key'];
  static indices = ['groupId'];

  config() {
    return AppConfig.pollTypes[this.pollType];
  }

  defaultValues() {
    return {
      anonymous: false,
      groupId: null,
      title: '',
      details: '',
      detailsFormat: 'html',
      defaultDurationInDays: 7,
      specifiedVotersOnly: false,
      pollType: null,
      chartType: null,
      minScore: null,
      maxScore: null,
      minimumStanceChoices: null,
      maximumStanceChoices: null,
      dotsPerPerson: null,
      canRespondMaybe: true,
      meetingDuration: null,
      limitReasonLength: true,
      stanceReasonRequired: 'optional',
      tags: [],
      files: [],
      imageFiles: [],
      attachments: [],
      linkPreviews: [],
      notifyOnClosingSoon: 'undecided_voters',
      reasonPrompt: null,
      processName: null,
      processSubtitle: null,
      processIntroduction: null,
      processIntroductionFormat: 'html',
      processUrl: null,
      pollOptions: [],
      pollOptionNameFormat: 'plain',
      shuffleOptions: false,
      hideResults: 'off',
      position: 0,
      outcomeStatement: null,
      outcomeStatementFormat: 'html',
      outcomeReviewDueInDays: null
    };
  }

  relationships() {
    this.belongsTo('author', {from: 'users'});
    return this.belongsTo('group');
  }

  buildPoll() {
    const poll = this.recordStore.polls.build();

    const attrs = pick(this, Object.keys(this.defaultValues()));
    attrs.pollTemplateId = this.id;
    attrs.pollTemplateKey = this.key;
    attrs.authorId = Session.user().id;
    attrs.closingAt = startOfHour(addDays(new Date(), this.defaultDurationInDays));
    attrs.pollOptionsAttributes = this.pollOptionsAttributes();

    poll.update(attrs);
    return poll;
  }

  pollOptionsAttributes() {
    return this.pollOptions.map(o => ({
      name: o.name,
      meaning: o.meaning,
      prompt: o.prompt,
      icon: o.icon
    }));
  }
};
