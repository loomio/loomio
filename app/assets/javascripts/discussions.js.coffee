window.Discussion ||= {}

# Set placeholders
$ ->
  if $("body.discussions.new").length > 0
    $('input, textarea').placeholder()

$ ->
  if $("body.discussions.show").length > 0

    if $('#js-dog-ear').length > 0 && !window.location.hash
      $('html,body').animate
        scrollTop: $('#js-dog-ear').offset().top - 75

    autocomplete_path = $('#comment-input').data('autocomplete-path')
    $("textarea#new-comment").atwho
      at: '@'
      tpl: "<li id='${id}' data-value='@${username}'> ${real_name} <small> @${username}</small></li>"
      callbacks:
        remote_filter: (query, callback) ->
          $.getJSON autocomplete_path, {q: query} , (data) ->
            callback(data)

# Show translation div
$ ->
  $('.translate-parent').on 'click', '.translate-link', (event) ->
    parent = $(@).closest('.translate-parent')
    $(@).slideUp -> $(@).remove()
    parent.find('.translated').not(parent.find('.translate-parent .translated')).slideDown()

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

# moving discussion
warn_if_moving_discussion = ->
  form = $('.move-discussion-form')
  form.find('.warn-move').hide()
  
  selected_group_id = form.find("select[name=destination_group_id]").val()

  if form.data('private-discussion')
    group_ids = String(form.data('public-group-ids')).split(' ')
    target = form.find '.warn-move-will-make-public'
  else
    group_ids = String(form.data('hidden-group-ids')).split(' ')
    target = form.find '.warn-move-will-make-private'

  if _.include(group_ids, selected_group_id)
    target.show()

$ ->
  warn_if_moving_discussion()
  $(".move-discussion-form select").on 'change', (e) ->
    warn_if_moving_discussion()

$ ->
  $(".js-prompt-user-to-join-or-authenticate").on "click", (e) ->
    $('#prompt-user-to-join-or-authenticate').modal('show')

