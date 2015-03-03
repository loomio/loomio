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
    $("textarea").atwho
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


# markdown button controller
$ ->
  $('#uses_markdown').click ->
    if $('input[name="uses_markdown"]:checked').length > 0
      $('#markdown-buttons').show()
    else
      $('#markdown-buttons').hide()
$ ->
  $('#comment_uses_markdown').click ->
    if $('input[name="comment[uses_markdown]"]:checked').length > 0
      $('#markdown-buttons').show()
    else
      $('#markdown-buttons').hide()
$ ->
  $("button.mdbtn").click (event) ->
    caret = Markdown.getCaret()
    Markdown.appendAtCaret($(this).attr('data-action'),caret)
    $(this).blur()
    $('textarea').focus()
    event.preventDefault()

Markdown =

  getCaret: () ->
    if $("textarea").prop("selectionStart")
      return $("textarea").prop("selectionStart")
    else if document.selection
      $("textarea").focus()
      r = document.selection.createRange()
      return 0 unless r?
      re = $("textarea").createTextRange()
      rc = re.duplicate()
      re.moveToBookmark r.getBookmark()
      rc.setEndPoint "EndToStart", re
      return rc.text.length

  appendAtCaret: (type, caret) ->
    beg = ""
    end = ""
    infix = ""
    $value = ""
    $target = $("textarea")
    value = $target.val()
    startPos = $target.prop("selectionStart")
    endPos = $target.prop("selectionEnd")
    scrollTop = $target.scrollTop
    infix = value.substring(startPos, endPos)
    lastChar = infix.substring(-1)
    # remove last newline if it is there
    newLine = /[\r\n]/g
    if newLine.test(lastChar)
      endPos = endPos - 1
      infix = value.substring(startPos, endPos)

    #split the list into lines according to our regex
    list = infix.split(newLine)

    count = 1
    clear = false
    switch type
      when "header"
        beg = "# "
        end = "\n"
      when "bold"
        beg = "**"
        end = "**"
      when "italic"
        beg = "*"
        end = "*"
      when "strike"
        beg = "~~"
        end = "~~"
      when "ul"
        for line in list
          do ->
            beg = beg + "\n- " + line
        end = "\n"
        clear = true
      when "ol"
        for line in list
          do ->
            beg = beg + "\n " + count + ". " + line
            count++
        end = "\n"
        clear = true
      when "link"
        beg = "[link text]("
        end = ")"
      when "image"
        beg = "![image alt text]("
        end = ")"
      when "hr"
        beg = "\n\n***\n\n"
        end = ""
    unless caret is value.length
      if clear is true
        infix = ""
      if caret is undefined
        caret = 0
      $target.val value.substring(0, caret) + beg + infix + end + value.substring(endPos, value.length)
      $target.prop "selectionStart", startPos
      $target.prop "selectionEnd", startPos + beg.length + end.length + value.substring(startPos, endPos).length
      $target.scrollTop = scrollTop
    else if caret is 0
      if type is "hr"
        $target.val value.substring(0, caret) + beg + value.substring(startPos, endPos) + end + value.substring(endPos, value.length)
        $target.prop "selectionStart", startPos
        $target.prop "selectionEnd", startPos + beg.length + end.length + value.substring(startPos, endPos).length
        $target.scrollTop = scrollTop
    else
      if type is "hr"
        $target.val value.substring(0, caret) + beg + value.substring(startPos, endPos) + end + value.substring(endPos, value.length)
        $target.prop "selectionStart", startPos
        $target.prop "selectionEnd", startPos + beg.length + end.length + value.substring(startPos, endPos).length
        $target.scrollTop = scrollTop
      else
        $target.val value + " " + $value
    return