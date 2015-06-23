angular.module('loomioApp').filter 'filterModel', ->
  (records = [], fragment) ->
    _.filter records, (record) ->
      _.some _.map record.constructor.searchableFields, (field) ->
        field = record[field]() if typeof record[field] == 'function'
        ~field.search new RegExp(fragment, 'i') if field? and field.search?
