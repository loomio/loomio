import BaseModel  from  '@/shared/record_store/base_model';
import Records  from  '@/shared/services/records';
import {map, parseInt, slice, max} from 'lodash';
import { exact } from '@/shared/helpers/format_time';
import { parseISO } from 'date-fns';
import I18n from '@/i18n';

export default class PollOptionModel extends BaseModel {
  static singular = 'pollOption';
  static plural = 'pollOptions';
  static indices = ['pollId'];
  static uniqueIndices = ['id'];
  static serializableAttributes = ['id', 'name', 'icon', 'priority', 'meaning', 'prompt'];

  defaultValues() {
    return {
      voterScores: {},
      name: null,
      icon: null,
      meaning: null,
      prompt: null,
      priority: null,
      _destroy: null
    };
  }

  relationships() {
    return this.belongsTo('poll');
  }

  stances() {
    return this.poll().latestStances().filter(s => s.pollOptionIds().includes(this.id));
  }

  beforeRemove() {
    return this.stances().forEach(stance => stance.remove());
  }

  optionName() {
    const poll = this.poll();
    switch (poll.pollOptionNameFormat) {
      case 'plain': return this.name;
      case 'i18n': return I18n.t('poll_' + poll.pollType + '_options.' + this.name);
      case 'iso8601': return exact(parseISO(this.name));
      default:
        return console.error('unsupported option format', poll.pollOptionNameFormat);
    }
  }
};
