import BaseModel        from '@/shared/record_store/base_model';
import AppConfig        from '@/shared/services/app_config';
import Session          from '@/shared/services/session';
import { pick }            from 'lodash-es';
import { startOfHour, addDays } from 'date-fns';
import { I18n }             from '@/i18n';
import Records from '@/shared/services/records';

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
      files: null,
      imageFiles: null,
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
      showNoneOfTheAbove: false,
      hideResults: 'off',
      position: 0,
      quorumPct: null,
      outcomeStatement: null,
      outcomeStatementFormat: 'html',
      outcomeReviewDueInDays: null,
      example: false
    };
  }

  collabKeyParams(){
    return [this.groupId, this.key];
  }

  relationships() {
    this.belongsTo('author', {from: 'users'});
    return this.belongsTo('group');
  }

  buildPoll() {
    const poll = Records.polls.build();

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
      icon: o.icon,
      testOperator: o.test_operator,
      testPercent: o.test_percent,
      testAgainst: o.test_against
    }));
  }

  translatedPollType() {
    return I18n.global.t(`poll_types.${this.pollType}`);
  }
};
