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
                                                UserRecordsInterface,
                                                SearchResultRecordsInterface,
                                                ContactRecordsInterface,
                                                InvitationRecordsInterface,
                                                InvitationFormRecordsInterface,
                                                VersionRecordsInterface,
                                                DraftRecordsInterface,
                                                TranslationRecordsInterface,
                                                OauthApplicationRecordsInterface,
                                                SessionRecordsInterface,
                                                RegistrationRecordsInterface,
                                                PollRecordsInterface,
                                                PollOptionRecordsInterface,
                                                StanceRecordsInterface,
                                                StanceChoiceRecordsInterface,
                                                OutcomeRecordsInterface,
                                                PollDidNotVoteRecordsInterface,
                                                VisitorRecordsInterface,
                                                IdentityRecordsInterface,
                                                CommunityRecordsInterface,
                                                PollCommunityRecordsInterface,
<<<<<<< HEAD
                                                ContactMessageRecordsInterface) ->
=======
                                                GroupIdentityRecordsInterface) ->
>>>>>>> master
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
  recordStore.addRecordsInterface(UserRecordsInterface)
  recordStore.addRecordsInterface(SearchResultRecordsInterface)
  recordStore.addRecordsInterface(ContactRecordsInterface)
  recordStore.addRecordsInterface(InvitationRecordsInterface)
  recordStore.addRecordsInterface(InvitationFormRecordsInterface)
  recordStore.addRecordsInterface(TranslationRecordsInterface)
  recordStore.addRecordsInterface(VersionRecordsInterface)
  recordStore.addRecordsInterface(DraftRecordsInterface)
  recordStore.addRecordsInterface(OauthApplicationRecordsInterface)
  recordStore.addRecordsInterface(SessionRecordsInterface)
  recordStore.addRecordsInterface(RegistrationRecordsInterface)
  recordStore.addRecordsInterface(PollRecordsInterface)
  recordStore.addRecordsInterface(PollOptionRecordsInterface)
  recordStore.addRecordsInterface(StanceRecordsInterface)
  recordStore.addRecordsInterface(StanceChoiceRecordsInterface)
  recordStore.addRecordsInterface(OutcomeRecordsInterface)
  recordStore.addRecordsInterface(PollDidNotVoteRecordsInterface)
  recordStore.addRecordsInterface(VisitorRecordsInterface)
  recordStore.addRecordsInterface(IdentityRecordsInterface)
  recordStore.addRecordsInterface(CommunityRecordsInterface)
  recordStore.addRecordsInterface(PollCommunityRecordsInterface)
  recordStore.addRecordsInterface(ContactMessageRecordsInterface)
  recordStore.addRecordsInterface(GroupIdentityRecordsInterface)
  recordStore
