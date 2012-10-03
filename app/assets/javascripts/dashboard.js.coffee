#*** ajax for discussions ***

# discussions
$ ->
  params = Application.getPageParam()
  $('#user-discussions').load("/discussions" + params, ->
    Application.convertUtcToRelativeTime()
    $("#user-discussions").removeClass('hidden')
    $("#discussions-loading").addClass('hidden')
  )
  $("#all-discussions-loading").addClass('hidden')
$ ->
  $(document).on('click', '#user-discussions .pagination a', (e)->
    unless $(this).parent().hasClass("gap")
      if Application.html5.supported
        window.history.pushState("stateObj", "title_ignored", Application.getNextURL($(this).attr("href")))
      $("#discussion-list").addClass('hidden')
      $("#discussions-loading").removeClass('hidden')
      $('#user-discussions').load($(this).attr('href'), ->
        Application.convertUtcToRelativeTime()
        $("#discussion-list").removeClass('hidden')
        $("#discussions-loading").addClass('hidden')
      )
      e.preventDefault()
  )
