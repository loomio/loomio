# Set placeholders
$ ->
  if $("body.discussions.new").length > 0
    $('input, textarea').placeholder()

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
    $("textarea").atWho "@", 
      cache: false
      tpl: "<li id='${id}' data-value='${username}'> ${name} <small> @${username}</small></li>"
      callback: (query, callback) ->
        group = $("#comment-input").data("group")
        $.get "/groups/#{group}/members", pre: query, ((result) ->
            #TODO tidy this up
            names = _.toArray(result)
            names = _.map names, (name) ->
              _.toArray(name)
            callback _.toArray(names)
        ), "json"

$ ->
  if $("body.discussions.show").length > 0
    $(".toggle-markdown").click((event) ->
        if $("#uses_markdown").val() == 'true'
          $("#uses_markdown").val(false)
        else
          $("#uses_markdown").val(true)
        $(".toggle-markdown").find('.icon-ok').removeClass('icon-ok')
        $(this).children().first().children().addClass('icon-ok')
        $("#markdown-settings-form").submit()
        event.preventDefault()
    )
