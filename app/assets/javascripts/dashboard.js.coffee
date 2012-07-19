#*** ajax for discussions ***

#closed proposals
$ ->
  $('#user-closed-motions').load("/motions")
$ ->
  $(document).on('click', '#user-closed-motions .pagination a', (e)->
    $('#user-closed-motions').load($(this).attr('href'))
    e.preventDefault()
  )

# discussions
$ ->
  $('#user-discussions').load("/discussions",
    Application.convertUtcToRelativeTime)
#$ ->
  $(document).on('click', '#user-discussions .pagination a', (e)->
    $('#user-discussions').load($(this).attr('href'),
      Application.convertUtcToRelativeTime)
    e.preventDefault()
  )
