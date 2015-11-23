angular.module('loomioApp').factory 'Records', (RecordStore,
                                                RecordStoreDatabaseName,
                                                AttachmentRecordsInterface,
                                                CommentRecordsInterface,
                                                DiscussionRecordsInterface,
                                                EventRecordsInterface,
                                                GroupRecordsInterface,
                                                MembershipRecordsInterface,
                                                MembershipRequestRecordsInterface,
                                                NotificationRecordsInterface,
                                                ProposalRecordsInterface,
                                                UserRecordsInterface,
                                                VoteRecordsInterface,
                                                DidNotVoteRecordsInterface,
                                                SearchResultRecordsInterface,
                                                ContactRecordsInterface,
                                                InvitationRecordsInterface,
                                                VersionRecordsInterface,
                                                DraftRecordsInterface) ->
  db = new loki(RecordStoreDatabaseName)
  recordStore = new RecordStore(db)
  recordStore.addRecordsInterface(AttachmentRecordsInterface)
  recordStore.addRecordsInterface(CommentRecordsInterface)
  recordStore.addRecordsInterface(DiscussionRecordsInterface)
  recordStore.addRecordsInterface(EventRecordsInterface)
  recordStore.addRecordsInterface(GroupRecordsInterface)
  recordStore.addRecordsInterface(MembershipRecordsInterface)
  recordStore.addRecordsInterface(MembershipRequestRecordsInterface)
  recordStore.addRecordsInterface(NotificationRecordsInterface)
  recordStore.addRecordsInterface(ProposalRecordsInterface)
  recordStore.addRecordsInterface(UserRecordsInterface)
  recordStore.addRecordsInterface(VoteRecordsInterface)
  recordStore.addRecordsInterface(DidNotVoteRecordsInterface)
  recordStore.addRecordsInterface(SearchResultRecordsInterface)
  recordStore.addRecordsInterface(ContactRecordsInterface)
  recordStore.addRecordsInterface(InvitationRecordsInterface)
  recordStore.addRecordsInterface(VersionRecordsInterface)
  recordStore.addRecordsInterface(DraftRecordsInterface)
  recordStore
