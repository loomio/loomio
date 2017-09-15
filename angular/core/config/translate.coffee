angular.module('loomioApp').config ($translateProvider) ->
  $translateProvider.useStaticFilesLoader(prefix: '/translations/', suffix: '.json')
                    .useSanitizeValueStrategy('escapeParameters')
                    .preferredLanguage(window.Loomio.currentUserLocale || 'en')
