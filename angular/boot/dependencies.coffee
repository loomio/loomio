if (bowser.safari and bowser.version < 9) or
   (bowser.ie and bowser.version < 10)
  window.location.href = "/417.html"

angular.module('loomioApp', [
  'ngNewRouter',
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
  'angularMoment',
  'offClick',
  'ngMaterial',
  'angulartics',
  'angulartics.google.tagmanager',
  'vcRecaptcha',
  'ngAnimate'
])
