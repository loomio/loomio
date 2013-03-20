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

# post Comment markdown buttons
$ ->
  if $("body.discussions.show").length > 0
    $("#comment-markdown-dropdown .enable-markdown").click((event) ->
      updateMarkdownUserSetting(this, true)
    )
$ ->
  if $("body.discussions.show").length > 0
    $("#comment-markdown-dropdown .disable-markdown").click((event) ->
      updateMarkdownUserSetting(this, false)
    )

updateMarkdownUserSetting = (selected, usesMarkdown) ->
  $('#comment-markdown-dropdown .uses_markdown').val(usesMarkdown)
  $('#comment-markdown-dropdown .markdown-setting-dropdown').find('.icon-ok').removeClass('icon-ok')
  $(selected).children().first().children().addClass('icon-ok')
  $("#markdown-settings-form").submit()
  event.preventDefault()

# create Discussion markdown buttons
$ ->
  if $("body.discussions.new").length > 0
    $("#enable-markdown").click((event) ->
      updateMarkdownSetting(this, true)
    )
$ ->
  if $("body.discussions.new").length > 0
    $("#disable-markdown").click((event) ->
      updateMarkdownSetting(this, false)
    )

# edit Discussion description makdown buttons
$ ->
  if $("body.discussions.show").length > 0
    $("#discussion-markdown-dropdown .enable-markdown").click((event) ->
      updateMarkdownForDiscussion(this, true)
    )
$ ->
  if $("body.discussions.show").length > 0
    $("#discussion-markdown-dropdown .disable-markdown").click((event) ->
      updateMarkdownForDiscussion(this, false)
    )

updateMarkdownForDiscussion = (selected, usesMarkdown) ->
  $('#description-edit-form .uses_markdown').val(usesMarkdown)
  $('#discussion-markdown-dropdown .uses_markdown').val(usesMarkdown)
  $('#discussion-markdown-dropdown .markdown-setting-dropdown').find('.icon-ok').removeClass('icon-ok')
  $(selected).children().first().children().addClass('icon-ok')
  image_tag = $('#discussion-markdown-dropdown-link')
  if usesMarkdown
    image_tag.html("<img alt='Markdown_on' class='markdown-icon markdown-on' src='/assets/markdown_on.png'>")
  else
    image_tag.html("<img alt='Markdown_off' class='markdown-icon markdown-off' src='/assets/markdown_off.png'>")
