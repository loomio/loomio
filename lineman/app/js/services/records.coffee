angular.module('loomioApp').factory 'Records', (RecordStore,
                                                RecordStoreDatabaseName,
                                                AttachmentModel,
                                                CommentModel,
                                                DiscussionModel,
                                                EventModel,
                                                GroupModel,
                                                MembershipModel,
                                                NotificationModel,
                                                ProposalModel,
                                                UserModel,
                                                VoteModel) ->
  db = new loki(RecordStoreDatabaseName)
  store = new RecordStore(db)
  store.addCollection(AttachmentModel)
  store.addCollection(CommentModel)
  store.addCollection(DiscussionModel)
  store.addCollection(EventModel)
  store.addCollection(GroupModel)
  store.addCollection(MembershipModel)
  store.addCollection(NotificationModel)
  store.addCollection(ProposalModel)
  store.addCollection(UserModel)
  store.addCollection(VoteModel)
  store
