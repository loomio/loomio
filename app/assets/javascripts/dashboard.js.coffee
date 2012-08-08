#*** ajax for discussions ***

#closed proposals
$ ->
  $('#user-closed-motions').load("/motions", ->
    $("#closed-motions-loading").hide()
  )
$ ->
  $(document).on('click', '#user-closed-motions .pagination a', (e)->
    unless $(this).parent().hasClass("gap")
      $("#closed-motion-list").hide()
      $("#closed-motions-loading").show()
      $('#user-closed-motions').load($(this).attr('href'), ->
        $("#closed-motion-list").show()
        $("#closed-motions-loading").hide()
        #$(".graph-preview").load(
      )
      e.preventDefault()
  )

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
