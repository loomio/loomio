angular.module('loomioApp').config ($translateProvider) ->
  $translateProvider.useSanitizeValueStrategy('escapeParameters')
                    .useStaticFilesLoader(prefix: '/translations/', suffix: '.json')
                    .preferredLanguage(window.Loomio.currentUserLocale || 'en')
