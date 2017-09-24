angular.module('loomioApp').config ($mdThemingProvider, $mdAriaProvider) ->
  theme = window.Loomio.theme

  if theme.custom_primary_palette
    $mdThemingProvider.definePalette('custom_primary', theme.custom_primary_palette)
    $mdThemingProvider.theme('default').primaryPalette('custom_primary', theme.primary_palette_config)
  else
    $mdThemingProvider.theme('default').primaryPalette(theme.primary_palette, theme.primary_palette_config)

  if theme.custom_accent_palette
    $mdThemingProvider.definePalette('custom_accent', theme.custom_accent_palette)
    $mdThemingProvider.theme('default').accentPalette('custom_accent', theme.accent_palette_config);
  else
    $mdThemingProvider.theme('default').accentPalette(theme.accent_palette, theme.accent_palette_config);

  $mdAriaProvider.disableWarnings();
