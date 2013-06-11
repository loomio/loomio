window.Discussion ||= {}

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


# Global Markdown (new discussion & comments)
$ ->
  if $("body.discussions.show").length > 0 || $("body.discussions.new").length > 0 || $("body.discussions.create").length > 0
    $(".global-markdown-setting .enable-markdown").click((event) ->
      img_to_replace = $('.global-markdown-setting').children().first()
      img_to_replace.html('<img alt="Markdown_on" class="markdown-icon markdown-on" src="/assets/markdown_on.png">')
      updateMarkdownSetting(this, true)
    )
$ ->
  if $("body.discussions.show").length > 0 || $("body.discussions.new").length > 0 || $("body.discussions.create").length > 0
    $(".global-markdown-setting .disable-markdown").click((event) ->
      img_to_replace = $('.global-markdown-setting').children().first()
      img_to_replace.html('<img alt="Markdown_off" class="markdown-icon markdown-off" src="/assets/markdown_off.png">')
      updateMarkdownSetting(this, false)
    )

updateMarkdownSetting = (selected, usesMarkdown) ->
  $("#global-uses-markdown").val(usesMarkdown)
  $('.global-markdown-setting .markdown-setting-dropdown').find('.icon-ok').removeClass('icon-ok')
  $(selected).children().first().children().addClass('icon-ok')
  event.preventDefault()

# Edit description
Discussion.enableInlineEdition = ()->
  Application.enableInlineEdition

   #edit description markdown setting
  $(".local-markdown-setting .enable-markdown").click((event) ->
    img_to_replace = $('#discussion-markdown-dropdown-link')
    img_to_replace.html('<img alt="Markdown_on" class="markdown-icon markdown-on" src="/assets/markdown_on.png">')
    editDescriptionMarkdownSetting(this, true)
  )

  $(".local-markdown-setting .disable-markdown").click((event) ->
    img_to_replace = $('#discussion-markdown-dropdown-link')
    img_to_replace.html('<img alt="Markdown_off" class="markdown-icon markdown-off" src="/assets/markdown_off.png">')
    editDescriptionMarkdownSetting(this, false)
  )

  editDescriptionMarkdownSetting = (selected, usesMarkdown) ->
    $('#description-markdown-setting').val(usesMarkdown)
    $('.local-markdown-setting .markdown-setting-dropdown').find('.icon-ok').removeClass('icon-ok')
    $(selected).children().first().children().addClass('icon-ok')
    event.preventDefault()

$ ->
  Discussion.enableInlineEdition()
