import BaseModel       from '@/shared/record_store/base_model';
import AppConfig       from '@/shared/services/app_config';
import HasTranslations from '@/shared/mixins/has_translations';
import AnonymousUserModel   from '@/shared/models/anonymous_user_model';
import i18n from '@/i18n';
import { sumBy, map, head, each, compact, flatten, includes, find, sortBy, parseInt } from 'lodash';

const stancesBecameUpdatable = new Date("2020-08-11");

export default class StanceModel extends BaseModel {
  static singular = 'stance';
  static plural = 'stances';
  static indices = ['pollId', 'latest', 'participantId'];
  static uniqueIndices = ['id'];

  afterConstruction() {
    return HasTranslations.apply(this);
  }

  defaultValues() {
    return {
      reason: '',
      reasonFormat: 'html',
      files: [],
      imageFiles: [],
      attachments: [],
      linkPreviews: [],
      revokedAt: null,
      participantId: null,
      pollId: null,
      optionScores: {},
      castAt: null
    };
  }

  relationships() {
    this.belongsTo('poll');
    return this.belongsTo('participant', {from: 'users'});
  }

  edited() {
    if (this.createdAt > stancesBecameUpdatable) {
      return this.versionsCount > 2;
    } else {
      return this.versionsCount > 1;
    }
  }

  discussion() { return this.poll().discussion(); }
  participantName() {
    if (this.participant()) {
      return this.participant().nameWithTitle(this.poll().group());
    } else {
      return i18n.t('common.anonymous');
    }
  }

  reactions() {
    return this.recordStore.reactions.find({reactableId: this.id, reactableType: "Stance"});
  }

  singleChoice() { return this.poll().singleChoice(); }
  hasOptionIcon() { return this.poll().config().has_option_icon; }

  participantIds() {
    return this.poll().participantIds();
  }

  memberIds() {
    return this.poll().memberIds();
  }

  group() {
    return this.poll().group();
  }

  isBlank() {
    return (this.reason === '') || (this.reason === null) || (this.reason === '<p></p>');
  }

  author() {
    return this.participant();
  }

  stanceChoice() {
    return head(this.sortedChoices());
  }

  pollOption() {
    if (this.pollOptionId()) { return this.recordStore.pollOptions.find(this.pollOptionId()); }
  }

  pollOptionId() {
    return this.pollOptionIds()[0];
  }

  pollOptionIds() {
    return map(Object.keys(this.optionScores), parseInt);
  }

  pollOptions() {
    return this.recordStore.pollOptions.find(this.pollOptionIds());
  }

  choose(optionIds) {
    this.optionScores = {};
    compact(flatten([optionIds])).forEach(function(id) {
      return this.optionScores[id] = 1;
    });
    return this;
  }

  sortedChoices() {
    const optionsById = {};
    this.pollOptions().forEach(o => optionsById[o.id] = o);
    const poll = this.poll();

    let choices = map(this.optionScores, (score, pollOptionId) => {
      return {
        score,
        rank: (poll.pollType === 'ranked_choice') && ((poll.minimumStanceChoices - score) + 1),
        show: (score > 0) || (poll.pollType === "score"),
        pollOption: optionsById[pollOptionId]
      };
  });

    choices = choices.filter(c => c.pollOption);

    if (poll.pollType === 'meeting') {
      return sortBy(choices, c => c.pollOption.priority);
    } else {
      return sortBy(choices, '-score');
    }
  }

  votedFor(option) {
    return includes(map(this.pollOptions(), 'id'), option.id);
  }

  scoreFor(option) {
    return this.optionScores[option.id] || 0;
  }

  totalScore() {
    return sumBy(this.sortedChoices(), 'score');
  }
};
