angular.module('loomioApp', ['ngRoute',
                             'ui.bootstrap',
                             'ui.bootstrap.datetimepicker',
                             'pascalprecht.translate',
                             'ngSanitize',
                             'tc.chartjs',
                             'btford.markdown',
                             'angularFileUpload',
                             'mentio',
                             'ngAnimate',
                             'angular-inview']).config ($httpProvider) ->

  # consume the csrf token from the page so form submissions can work
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken

angular.module('loomioApp').config ($translateProvider) ->
  $translateProvider.
    useUrlLoader('/api/v1/translations/en').
    preferredLanguage('en')

angular.module('loomioApp').run (Records, UserAuthService) ->
  if window? and window.Loomio?
    Records.import(window.Loomio.seedRecords)
    UserAuthService.currentUser = Records.users.find(window.Loomio.currentUserId)

