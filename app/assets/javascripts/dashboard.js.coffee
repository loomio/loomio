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
  if $("body.dashboard.show").length > 0
    $('.new-discussion-link').click((e) ->
      $('#new-discussion').find('#group_id').val($(this).children().first().data('group'))
    )