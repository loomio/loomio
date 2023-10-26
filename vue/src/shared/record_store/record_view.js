/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let RecordView;
export default RecordView = (function() {
  RecordView = class RecordView {
    static initClass() {
      this.prototype.collectionNames = [];
      this.prototype.name = "unnamedView";
    }

    constructor({name, recordStore, collections,  query}) {
      this.name = name;
      this.recordStore = recordStore;
      this.collectionNames = collections;
      this.query = query;
      this.query(this.recordStore);
    }
  };
  RecordView.initClass();
  return RecordView;
})();
