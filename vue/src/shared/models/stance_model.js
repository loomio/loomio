import BaseModel       from '@/shared/record_store/base_model';
import HasTranslations from '@/shared/mixins/has_translations';
import { I18n } from '@/i18n';
import { sumBy, map, head, compact, flatten, includes, sortBy } from 'lodash-es';
import Records from '@/shared/services/records';

const stancesBecameUpdatable = new Date("2020-08-11");

export default class StanceModel extends BaseModel {
  static singular = 'stance';
  static plural = 'stances';
  static indices = ['pollId', 'latest', 'participantId'];
  static uniqueIndices = ['id'];

  afterConstruction() {
    HasTranslations.apply(this);
  }

  collabKeyParams() {
    return [this.pollId];
  }

  defaultValues() {
    return {
      reason: '',
      reasonFormat: 'html',
      files: null,
      imageFiles: null,
      attachments: [],
      linkPreviews: [],
      revokedAt: null,
      participantId: null,
      pollId: null,
      optionScores: {},
      castAt: null,
      guest: false
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
      return I18n.global.t('common.anonymous');
    }
  }

  reactions() {
    return Records.reactions.find({reactableId: this.id, reactableType: "Stance"});
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
    if (this.pollOptionId()) { return Records.pollOptions.find(this.pollOptionId()); }
  }

  pollOptionId() {
    return this.pollOptionIds()[0];
  }

  pollOptionIds() {
    return Object.keys(this.optionScores).map(k => parseInt(k))
  }

  pollOptions() {
    return Records.pollOptions.find(this.pollOptionIds());
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
    this.poll().pollOptions().forEach(o => optionsById[o.id] = o);
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
    } else if (poll.pollType == 'ranked_choice') {
      return sortBy(choices, 'rank');
    } else {
      return sortBy(choices, '-score');
    }
  }

  votedFor(option) {
    return includes(map(this.pollOptions(), 'id'), option.id);
  }

  scoreFor(option) {
    return this.optionScores[option.id] || this.poll().minScore;
  }

  totalScore() {
    return sumBy(this.sortedChoices(), 'score');
  }
};
