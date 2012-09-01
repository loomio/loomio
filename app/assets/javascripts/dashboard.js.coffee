#*** ajax for discussions ***

# discussions
$ ->
  $('#user-discussions').load("/discussions", ->
    Application.convertUtcToRelativeTime()
    $("#user-discussions").removeClass('hidden')
    $("#discussions-loading").addClass('hidden')
  )
$ ->
  $(document).on('click', '#user-discussions .pagination a', (e)->
    unless $(this).parent().hasClass("gap")
      $("#discussion-list").addClass('hidden')
      $("#discussions-loading").removeClass('hidden')
      $('#user-discussions').load($(this).attr('href'), ->
        Application.convertUtcToRelativeTime()
        $("#discussion-list").removeClass('hidden')
        $("#discussions-loading").addClass('hidden')
      )
      e.preventDefault()
  )

#*** check if lists are empty ***
$ ->
  if $("body.dashboard.show").length > 0
    if $("#discussions-with-motions").children().html() == null &&  $("#user-discussions").children().html() == null
      $(".empty-list-message").removeClass('hidden')
