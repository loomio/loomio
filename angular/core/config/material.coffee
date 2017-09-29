angular.module('loomioApp').config ($mdThemingProvider, $mdAriaProvider) ->
  theme = window.Loomio.theme

  if theme.custom_primary_palette
    $mdThemingProvider.definePalette('custom_primary', theme.custom_primary_palette)

  if theme.custom_accent_palette
    $mdThemingProvider.definePalette('custom_accent', theme.custom_accent_palette)

  if theme.custom_warn_palette
    $mdThemingProvider.definePalette('custom_warn', theme.custom_warn_palette)

  $mdThemingProvider.theme('default').primaryPalette(theme.primary_palette, theme.primary_palette_config)
  $mdThemingProvider.theme('default').accentPalette(theme.accent_palette, theme.accent_palette_config);
  $mdThemingProvider.theme('default').warnPalette(theme.warn_palette, theme.warn_palette_config);

  $mdAriaProvider.disableWarnings();
