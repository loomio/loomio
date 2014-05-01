window.Discussion ||= {}

# Set placeholders
$ ->
  if $("body.discussions.new").length > 0
    $('input, textarea').placeholder()

$ ->
  if $("body.discussions.show").length > 0
    autocomplete_path = $('#comment-input').data('autocomplete-path')
    $("textarea").atwho
      at: '@'
      tpl: "<li id='${id}' data-value='@${username}'> ${real_name} <small> @${username}</small></li>"
      callbacks:
        remote_filter: (query, callback) ->
          $.getJSON autocomplete_path, {q: query} , (data) ->
            callback(data)

# Show translation div
$ ->
  $('.activity-item-container').on 'click', '.translate-comment', (event) ->
    $(this).slideUp().closest('.activity-item-body').find('.activity-item-translation').slideDown()

# Global Markdown (new discussion & comments)
$ ->
  $(".global-markdown-setting .enable-markdown").click (event) ->
    img_to_replace = $('.global-markdown-setting').children().first()
    img_to_replace.html('<img alt="Markdown_on" class="markdown-icon markdown-on" src="/assets/markdown_on.png">')
    updateMarkdownSetting(this, true)
    $('#discussion_uses_markdown').val('true')

  $(".global-markdown-setting .disable-markdown").click (event) ->
    img_to_replace = $('.global-markdown-setting').children().first()
    img_to_replace.html('<img alt="Markdown_off" class="markdown-icon markdown-off" src="/assets/markdown_off.png">')
    updateMarkdownSetting(this, false)
    $('#discussion_uses_markdown').val('false')

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

#adds bootstrap tooltips to discussion features
$ ->
  $("#js-dog-ear").tooltip
    placement: "right",
    title: "Here's where you read up to last time"

  $(".jump-to-add-comment").tooltip
    placement: "top",
    title: "Jump to add comment"

  $(".jump-to-latest-activity").tooltip
    placement: "top",
    title: "Jump to latest unread activity"

# moving discussion
warn_if_moving_discussion_to_private_group = ->
  $('.move-discussion-form .warn-move-will-make-private').hide()
  private_discussion = $(".move-discussion-form").data('private-discussion')
  unless private_discussion
    hidden_group_ids = String($(".move-discussion-form").data('hidden-group-ids')).split(' ')
    selected_group_id = $("select[name=destination_group_id]").val()
    if _.include(hidden_group_ids, selected_group_id)
      $('.move-discussion-form .warn-move-will-make-private').show()

$ ->
  warn_if_moving_discussion_to_private_group()
  $(".move-discussion-form select").on 'change', (e) ->
    warn_if_moving_discussion_to_private_group()

$ ->
  $(".js-prompt-user-to-join-or-authenticate").on "click", (e) ->
    $('#prompt-user-to-join-or-authenticate').modal('show')
