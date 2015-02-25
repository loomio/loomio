window.Application ||= {}
$ ->
  $('.intercom-proxy').on 'click', (e) ->
    e.preventDefault()
    $('#Intercom').trigger('click')

# keyboard shortcuts
$ ->

  $(".dismiss-help-notice").click (event)->
    $.post($(this).attr("href"))
    $('.help-notice').modal('hide')
    event.preventDefault()
    event.stopPropagation()

$ -> # check if discussion with motions list is empty
  if $("body.groups.show").length > 0 ||  $("body.dashboard.show").length > 0
    if $("#discussions-with-motions").children().html() != ""
      $(".discussion-with-motion-divider").removeClass('hidden')

# Placeholder shim
$.placeholder.shim();

# throws a warning if you try to navigate away from a page with unsaved form changes
# todo: translate the warning message
$ ->
  $('.js-warn-before-navigating-away').safetynet()

getParameterByName = (name) ->
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    regex = new RegExp("[\\?&]#{name}=([^&#]*)")
    results = regex.exec(location.search);
    if results == null
      ""
    else
      decodeURIComponent(results[1].replace(/\+/g, " "));

if locale = getParameterByName('locale')
  $.ajaxSetup(data: {locale: locale})
