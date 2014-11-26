angular.module('loomioApp').factory 'MainRecordStore', (RecordStore) ->
  db = new loki('main_record_store.db')
  new RecordStore(db)
