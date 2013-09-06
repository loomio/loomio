#*** ajax for discussions ***

# discussions
$ ->
  # params = Application.getPageParam()
  params = ""
  $('#user-discussions').load("/discussions" + params, ->
    Application.convertUtcToRelativeTime()
    $("#user-discussions").removeClass('hidden')
    $("#discussions-loading").addClass('hidden')
  )
  $("#all-discussions-loading").addClass('hidden')
$ ->
  $(document).on('click', '#user-discussions .pagination a', (e)->
    unless $(this).parent().hasClass("gap")
      # if Application.html5.supported
      #   window.history.pushState("stateObj", "title_ignored", Application.getNextURL($(this).attr("href")))
      $("#discussion-list").addClass('hidden')
      $("#discussions-with-motions").hide()
      $("#discussions-loading").removeClass('hidden')
      $('#user-discussions').load($(this).attr('href'), ->
        Application.convertUtcToRelativeTime()
        if document.URL.indexOf("page") == -1
          $("#discussions-with-motions").show()
        $("#discussion-list").removeClass('hidden')
        $("#discussions-loading").addClass('hidden')
      )
      e.preventDefault()
  )

$ ->
  if $("body.groups.show").length > 0 || $("body.dashboard.show").length > 0
    $('.motion-sparkline').sparkline('html', { type: 'pie', height: '26px', width: '26px', sliceColors: [ "#90D490", "#F0BB67", "#D49090", "#dd0000", '#ccc'], disableTooltips: 'true' })
