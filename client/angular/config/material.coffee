AppConfig = require 'shared/services/app_config'

angular.module('loomioApp').config ['$mdThemingProvider', '$mdAriaProvider', ($mdThemingProvider, $mdAriaProvider) ->
  if AppConfig.theme.custom_primary_palette
    $mdThemingProvider.definePalette('custom_primary', AppConfig.theme.custom_primary_palette)

  if AppConfig.theme.custom_accent_palette
    $mdThemingProvider.definePalette('custom_accent', AppConfig.theme.custom_accent_palette)

  if AppConfig.theme.custom_warn_palette
    $mdThemingProvider.definePalette('custom_warn', AppConfig.theme.custom_warn_palette)

  $mdThemingProvider.theme('default').primaryPalette(AppConfig.theme.primary_palette, AppConfig.theme.primary_palette_config)
  $mdThemingProvider.theme('default').accentPalette(AppConfig.theme.accent_palette, AppConfig.theme.accent_palette_config);
  $mdThemingProvider.theme('default').warnPalette(AppConfig.theme.warn_palette, AppConfig.theme.warn_palette_config);

  $mdAriaProvider.disableWarnings();
]
