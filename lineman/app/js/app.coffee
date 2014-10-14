angular.module('loomioApp', ['ngRoute', 'jmdobry.angular-cache', 'ui.bootstrap.datetimepicker','pascalprecht.translate', 'tc.chartjs']).config ($httpProvider) ->
  # consume the csrf token from the page
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken

angular.module('loomioApp').config ($translateProvider) ->
  $translateProvider.
    useUrlLoader('/api/v1/translations/en').
    preferredLanguage('en');

# setup the RecordStoreService so that it knows about all the models we care about
angular.module('loomioApp').run (RecordStoreService,
                                 UserModel,
                                 CommentModel,
                                 DiscussionModel,
                                 ProposalModel,
                                 EventModel,
                                 VoteModel) ->

  RecordStoreService.registerModel(UserModel)
  RecordStoreService.registerModel(ProposalModel)
  RecordStoreService.registerModel(DiscussionModel)
  RecordStoreService.registerModel(CommentModel)
  RecordStoreService.registerModel(EventModel)
  RecordStoreService.registerModel(VoteModel)
