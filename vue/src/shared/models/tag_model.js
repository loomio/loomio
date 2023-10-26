/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let TagModel;
import BaseModel            from '@/shared/record_store/base_model';
import VuetifyColors  from 'vuetify/lib/util/colors';

const colors = Object.keys(VuetifyColors).filter(name => name !== 'shades').map(name => VuetifyColors[name]['base']);

export default TagModel = (function() {
  TagModel = class TagModel extends BaseModel {
    static initClass() {
      this.singular = 'tag';
      this.plural = 'tags';
      this.uniqueIndices = ['id'];
      this.indices = ['groupId'];
      this.colors = colors;
    }

    defaultValues() {
      return {color: colors[Math.floor(Math.random() * colors.length)]};
    }

    relationships() {
      return this.belongsTo('group');
    }
  };
  TagModel.initClass();
  return TagModel;
})();
