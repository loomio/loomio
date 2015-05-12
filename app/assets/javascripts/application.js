// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.

//= require jquery
//= require jquery_ujs
//= require underscore
//= require moment
//= require jquery-ui/sortable
//= require jquery.atwho/index
//= require jquery-fileupload/basic
//= require jquery-fileupload/vendor/tmpl
//= require lib/jquery.cookie.js
//= require lib/jstz-1.0.4.min
//= require lib/jquery.sparkline.min
//= require lib/jquery.html5-placeholder-shim
//= require lib/jquery.placeholder
//= require lib/jquery.netchanger.min
//= require lib/jquery.safetynet
//= require lib/bootstrap-datetimepicker
//= require lib/Chart
//= require modernizr
//= require bootstrap
//= require bootstrap-custom
//= require main
//= require invitations
//= require validations
//= require groups
//= require group_requests
//= require discussions
//= require motions
//= require users
//= require notifications
//= require votes
//= require tooltips
//= require autodetect_time_zone
//= require inbox
//= require searches
//= require attachments
//= require subscriptions
//= require explore
//= require keyboard_shortcuts
//= require locale_selector
//= require ahoy

ahoy.trackView();
//ahoy.trackClicks();

if (navigator.userAgent.match(/IEMobile\/10\.0/)) {
  var msViewportStyle = document.createElement('style')
  msViewportStyle.appendChild(
    document.createTextNode(
      '@-ms-viewport{width:auto!important}'
    )
  )
  document.querySelector('head').appendChild(msViewportStyle)
}
