AppConfig = require 'shared/services/app_config'
Raven = require('raven-js');

if AppConfig.sentry_dsn
  ravenOptions =
    ignoreErrors: [
      'top.GLOBALS'
      'originalCreateNotification'
      'canvas.contentDocument'
      'MyApp_RemoveAllHighlights'
      'http://tt.epicplay.com'
      'Can\'t find variable: ZiteReader'
      'jigsaw is not defined'
      'ComboSearch is not defined'
      'http://loading.retry.widdit.com/'
      'atomicFindClose'
      'fb_xd_fragment'
      'bmi_SafeAddOnload'
      'EBCallBackMessageReceived'
      'conduitPage'
      'Script error.'
      'miscellaneous_bindings'
      'canonicalUrl'
      'TypeError: s.outlets[Object.keys(...)[0]]'
    ]
    ignoreUrls: [
      /graph\.facebook\.com/i
      /connect\.facebook\.net\/en_US\/all\.js/i
      /eatdifferent\.com\.woopra-ns\.com/i
      /static\.woopra\.com\/js\/woopra\.js/i
      /extensions\//i
      /^chrome:\/\//i
      /^resource:\/\//i
      /127\.0\.0\.1:4001\/isrunning/i
      /webappstoolbarba\.texthelp\.com\//i
      /metrics\.itunes\.apple\.com\.edgesuite\.net\//i
    ]
  Raven.config(AppConfig.sentry_dsn, ravenOptions)
       .addPlugin(require('raven-js/plugins/angular'), angular)
       .install();

module.exports = Raven
