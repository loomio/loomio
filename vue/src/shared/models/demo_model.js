/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let DemoModel;
import BaseModel        from '@/shared/record_store/base_model';

export default DemoModel = (function() {
  DemoModel = class DemoModel extends BaseModel {
    static initClass() {
      this.singular = 'demo';
      this.plural = 'demos';
      this.uniqueIndices = ['id'];
      this.indices = ['groupId', 'authorId'];
    }

    defaultValues() {
      return {
        id: null,
        name: null,
        description: null,
        groupId: null,
        demoHandle: null
      };
    }

    relationships() {
      this.belongsTo('group');
      return this.belongsTo('author', {from: 'users'});
    }
  };
  DemoModel.initClass();
  return DemoModel;
})();
