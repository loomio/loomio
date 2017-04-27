if (bowser.safari and bowser.version < 9) or
   (bowser.ie and bowser.version < 10)
  window.location.href = "/browser_not_supported"

angular.module('loomioApp', [
  'ngNewRouter',
  'ui.bootstrap',
  'pascalprecht.translate',
  'ngSanitize',
  'hc.marked',
  'angularFileUpload',
  'mentio',
  'ngAnimate',
  'angular-inview',
  'ui.gravatar',
  'duScroll',
  'angular-clipboard',
  'checklist-model',
  'monospaced.elastic',
  'angularMoment',
  'offClick',
  'ngMaterial',
  'angulartics',
  'angulartics.google.tagmanager'
])
