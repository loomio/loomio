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
  if $("body.discussions.show").length > 0
    $("textarea").atWho "@", 
      tpl: "<li id='${id}' data-value='${username}'> ${name} <small> @${username}</small></li>"
      callback: (query, callback) ->
        group = $("#comment-input").data("group")
        $.get "/users/mentions.json", q: query, group: group, ((result) ->
            console.log(result)
            names = _.toArray(result)
            names = _.map names, (name) ->
              _.toArray(name)
            callback _.toArray(names)
        ), "json"

#expand/srink description text
$ ->
  if $("body.discussions.show").length > 0
    $(".see-more").click((event) ->
      $(this).parent().children(".short-description").toggle()
      $(this).parent().children(".long-description").toggle()
      if $(this).html() == "Show More"
        $(this).html("Show Less")
      else
        $(this).html("Show More")
      event.preventDefault()
    )
