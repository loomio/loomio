angular.module('loomioApp', ['ngRoute',
                             'ui.bootstrap',
                             'ui.bootstrap.datetimepicker',
                             'pascalprecht.translate',
                             'ngSanitize',
                             'tc.chartjs',
                             'btford.markdown',
                             'infinite-scroll',
                             'angularFileUpload',
                             'mentio',
                             'ngAnimate']).config ($httpProvider) ->

  # consume the csrf token from the page
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken

angular.module('loomioApp').config ($translateProvider) ->
  $translateProvider.
    useUrlLoader('/api/v1/translations/en').
    preferredLanguage('en')

