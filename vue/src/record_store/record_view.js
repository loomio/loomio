export default class RecordView {
  constructor({name, recordStore, collections,  query}) {
    this.collectionNames = [];
    this.name = "unnamedView";
    
    this.collectionNames = collections;
    this.name = name;
    this.recordStore = recordStore;
    this.query = query;
    this.query(this.recordStore);
  }
};
