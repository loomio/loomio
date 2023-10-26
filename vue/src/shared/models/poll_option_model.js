/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let PollOptionModel;
import BaseModel  from  '@/shared/record_store/base_model';
import Records  from  '@/shared/services/records';
import {map, parseInt, slice, max} from 'lodash';
import { exact } from '@/shared/helpers/format_time';
import { parseISO } from 'date-fns';
import I18n from '@/i18n';

export default PollOptionModel = (function() {
  PollOptionModel = class PollOptionModel extends BaseModel {
    static initClass() {
      this.singular = 'pollOption';
      this.plural = 'pollOptions';
      this.indices = ['pollId'];
      this.uniqueIndices = ['id'];
      this.serializableAttributes = ['id', 'name', 'icon', 'priority', 'meaning', 'prompt'];
    }

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
  PollOptionModel.initClass();
  return PollOptionModel;
})();
