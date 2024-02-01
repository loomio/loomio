import BaseModel     from '@/shared/record_store/base_model';
import VuetifyColors from 'vuetify/lib/util/colors';

const colors = Object.keys(VuetifyColors).filter(name => name !== 'shades').map(name => VuetifyColors[name]['base']);

export default class TagModel extends BaseModel {
  static singular = 'tag';
  static plural = 'tags';
  static uniqueIndices = ['id'];
  static indices = ['groupId'];
  static colors = colors;

  defaultValues() {
    return {color: colors[Math.floor(Math.random() * colors.length)]};
  }

  relationships() {
    this.belongsTo('group');
  }
};
