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
    console.log("@who") 
    $.get "/users/mentions.json", q: query, ((result) ->
        console.log("in callback")
        console.log("result: ")
        console.log(result)
        #names = $.parseJSON(result)
        names = Array::slice.call(result)
        names = $.map(result, (value, key) -> 
          id: key
          name: value
          email: value + "@email.com"
        )
        console.log(names)
        callback names
    ), "json"

