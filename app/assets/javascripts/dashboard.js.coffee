#*** ajax for discussions ***

#closed proposals
$ ->
  $('#user-closed-motions').load("/motions", ->
    $("#closed-motions-loading").hide()
  )
$ ->
  $(document).on('click', '#user-closed-motions .pagination a', (e)->
    $("#user-closed-motions").hide()
    $("#closed-motions-loading").show()
    $('#user-closed-motions').load($(this).attr('href'), ->
      $("#user-closed-motions").show()
      $("#closed-motions-loading").hide()
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
    $("#user-discussions").hide()
    $("#discussions-loading").show()
    $('#user-discussions').load($(this).attr('href'), ->
      Application.convertUtcToRelativeTime()
      $("#user-discussions").show()
      $("#discussions-loading").hide()
    )
    e.preventDefault()
  )
