# Edit title
$ ->
  if $("body.discussions.show").length > 0
    $("#edit-title").click((event) ->
      $("#discussion-title").addClass('hidden')
      $("#edit-discussion-title").removeClass('hidden')
      event.preventDefault()
    )
    $("#cancel-edit-title").click((event) ->
      $("#edit-discussion-title").addClass('hidden')
      $("#discussion-title").removeClass('hidden')
      event.preventDefault()
    )

$ ->
  if $("body.discussions.show").length > 0
    $('textarea.at-mentions').atWho("@", (query, callback) ->
      url = "data.json",
      param = {'q':query},
      $.ajax(url, param, (data) ->
        names = $.parseJSON(data)
        callback(names)
        )
    )

