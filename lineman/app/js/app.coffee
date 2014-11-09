angular.module('loomioApp', ['ngRoute',
                             'jmdobry.angular-cache',
                             'ui.bootstrap',
                             'ui.bootstrap.datetimepicker',
                             'pascalprecht.translate',
                             'ngSanitize',
                             'tc.chartjs',
                             'btford.markdown',
                             'infinite-scroll',
                             'angularFileUpload']).config ($httpProvider) ->

  # consume the csrf token from the page
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken

angular.module('loomioApp').config ($translateProvider) ->
  $translateProvider.
    useUrlLoader('/api/v1/translations/en').
    preferredLanguage('en');

# setup the RecordStoreService so that it knows about all the models we care about
angular.module('loomioApp').run (RecordStoreService,
                                 GroupModel,
                                 UserModel,
                                 CommentModel,
                                 AttachmentModel,
                                 DiscussionModel,
                                 ProposalModel,
                                 EventModel,
                                 VoteModel) ->

  RecordStoreService.registerModel(GroupModel)
  RecordStoreService.registerModel(UserModel)
  RecordStoreService.registerModel(ProposalModel)
  RecordStoreService.registerModel(DiscussionModel)
  RecordStoreService.registerModel(CommentModel)
  RecordStoreService.registerModel(AttachmentModel)
  RecordStoreService.registerModel(EventModel)
  RecordStoreService.registerModel(VoteModel)
