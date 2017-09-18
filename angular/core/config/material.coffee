angular.module('loomioApp').config ($mdThemingProvider, $mdAriaProvider) ->
  theme = window.Loomio.theme
  $mdThemingProvider.theme('default')
    .primaryPalette(theme.primary_palette, theme.primary_palette_config)
    .accentPalette(theme.accent_palette, theme.accent_palette_config);
  $mdAriaProvider.disableWarnings();
