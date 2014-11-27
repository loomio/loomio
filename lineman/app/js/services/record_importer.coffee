angular.module('loomioApp').factory 'RecordImporter', (DiscussionCollection, CommentCollection) ->
  new class RecordImporter
    constructor: (collections) ->

    import: (data) ->
      # where keys in data correspond to keys in collection import the records

