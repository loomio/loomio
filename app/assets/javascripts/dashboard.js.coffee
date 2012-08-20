#*** ajax for discussions ***

# discussions
$ ->
  $('#user-discussions').load("/discussions", ->
    Application.convertUtcToRelativeTime()
    $("#user-discussions").show()
    $("#discussions-loading").hide()
  )
$ ->
  $(document).on('click', '#user-discussions .pagination a', (e)->
    unless $(this).parent().hasClass("gap")
      $("#discussion-list").hide()
      $("#discussions-loading").show()
      $('#user-discussions').load($(this).attr('href'), ->
        Application.convertUtcToRelativeTime()
        $("#discussion-list").show()
        $("#discussions-loading").hide()
      )
      e.preventDefault()
  )
