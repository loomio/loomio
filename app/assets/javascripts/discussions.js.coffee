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
    $(".edit-discussion-description").click (e)->
      $(".discussion-description-helper-text").toggle()

$ ->
  $("textarea").atWho "@", (query, callback) ->
    url = "/users/mentions.json"
    dataType = "json"
    contentType = "application/json"
    param = q: query
    $.ajax url, param, (data) ->
      console.log "in callback"
      console.log data
      names = $.parseJSON(data)
      callback names
