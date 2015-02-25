angular.module('loomioApp').factory 'Records', (RecordStore,
                                                RecordStoreDatabaseName,
                                                AttachmentRecordsInterface,
                                                CommentRecordsInterface,
                                                DiscussionRecordsInterface,
                                                DiscussionReaderRecordsInterface,
                                                EventRecordsInterface,
                                                GroupRecordsInterface,
                                                MembershipRecordsInterface,
                                                MembershipRequestRecordsInterface,
                                                NotificationRecordsInterface,
                                                ProposalRecordsInterface,
                                                UserRecordsInterface,
                                                VoteRecordsInterface,
                                                SearchResultRecordsInterface) ->
  db = new loki(RecordStoreDatabaseName)
  recordStore = new RecordStore(db)
  recordStore.addRecordsInterface(AttachmentRecordsInterface)
  recordStore.addRecordsInterface(CommentRecordsInterface)
  recordStore.addRecordsInterface(DiscussionRecordsInterface)
  recordStore.addRecordsInterface(DiscussionReaderRecordsInterface)
  recordStore.addRecordsInterface(EventRecordsInterface)
  recordStore.addRecordsInterface(GroupRecordsInterface)
  recordStore.addRecordsInterface(MembershipRecordsInterface)
  recordStore.addRecordsInterface(MembershipRequestRecordsInterface)
  recordStore.addRecordsInterface(NotificationRecordsInterface)
  recordStore.addRecordsInterface(ProposalRecordsInterface)
  recordStore.addRecordsInterface(UserRecordsInterface)
  recordStore.addRecordsInterface(VoteRecordsInterface)
  recordStore.addRecordsInterface(SearchResultRecordsInterface)
  recordStore
