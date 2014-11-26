angular.module('loomioApp').factory 'RecordStore', (CommentCollection, DiscussionCollection, UserCollection) ->
  class RecordStore
    constructor: (db) ->
      @db = db
      @comments = new CommentCollection(db)
      @discussions =  new DiscussionCollection(db)
      @users = new UserCollection(db)
