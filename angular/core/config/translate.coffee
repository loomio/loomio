angular.module('loomioApp').config ($translateProvider) ->
  $translateProvider.useUrlLoader("/api/v1/translations")
                    .useSanitizeValueStrategy('escapeParameters')
                    .preferredLanguage(window.Loomio.currentUserLocale)
