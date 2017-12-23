AppConfig = require 'shared/services/app_config.coffee'
RecordStore = require 'shared/interfaces/record_store.coffee'

angular.module('loomioApp').factory 'Records', (CommentRecordsInterface,
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
                                                IdentityRecordsInterface,
                                                ContactMessageRecordsInterface,
                                                GroupIdentityRecordsInterface,
                                                ReactionRecordsInterface,
                                                ContactRequestRecordsInterface,
                                                DocumentRecordsInterface) ->
  recordStore = new RecordStore()
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
  recordStore.addRecordsInterface(IdentityRecordsInterface)
  recordStore.addRecordsInterface(ContactMessageRecordsInterface)
  recordStore.addRecordsInterface(GroupIdentityRecordsInterface)
  recordStore.addRecordsInterface(ReactionRecordsInterface)
  recordStore.addRecordsInterface(ContactRequestRecordsInterface)
  recordStore.addRecordsInterface(DocumentRecordsInterface)
  recordStore
