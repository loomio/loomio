window.MarkdownSetup = {}

MarkdownSetup.init = () ->
  if MarkdownSetup.rendererRequired()
    MarkdownSetup.converter = Markdown.getSanitizingConverter();
    MarkdownSetup.converter.autoNewLine = true;
    MarkdownSetup.render_markdown()
    MarkdownSetup.startEditors()

MarkdownSetup.startEditors = () ->
  if $('.discussions.show').length > 0
    MarkdownSetup.start_comment_editor()
    MarkdownSetup.start_discussion_description_editor()
  if $('.discussions.new').length > 0
    MarkdownSetup.start_new_discussion_editor()
  if $('.new_proposal').length > 0
    MarkdownSetup.start_new_motion_editor()

MarkdownSetup.rendererRequired = () ->
  $('.discussions.show').length > 0 ||
    $('.groups.show').length > 0 ||
    $('.discussions.new').length > 0 ||
    $('.new_proposal').length > 0 ||
    $('.votes.new').length > 0

MarkdownSetup.showHelp = () ->
  $('#wmd-help').modal('toggle')
  return false

MarkdownSetup.start_discussion_description_editor = () ->
  editor1 = new Markdown.Editor(MarkdownSetup.converter, '-discussion-description', {handler: MarkdownSetup.showHelp});
  editor1.run();

MarkdownSetup.start_comment_editor = () ->
  editor2 = new Markdown.Editor(MarkdownSetup.converter, '-comment', {handler: MarkdownSetup.showHelp});
  editor2.run();

  # toggle comment preview on and off
  preview = $('#wmd-preview-comment');
  preview_button = $('#preview-comment');
  preview_button.click (event) ->
    preview.toggle 0, () -> preview_button.toggleClass('active')

  # toggle formatting buttons on and off
  button_bar = $('#wmd-button-bar-comment');
  formatting_button = $('#comment-formatting')
  formatting_button.click (event) ->
    button_bar.toggle 0, () -> formatting_button.toggleClass('active')
    $('#comment-toolbar .tooltip').toggle()

  # tooltips
  formatting_button.tooltip(placement: 'bottom')
  $('#add-attachment-icon').tooltip(placement: 'bottom')

MarkdownSetup.start_new_discussion_editor = () ->
  editor3 = new Markdown.Editor(MarkdownSetup.converter, '-new-discussion', {handler: MarkdownSetup.showHelp});
  editor3.run();

  # toggle preview on and off
  preview = $('#wmd-preview-new-discussion');
  preview_button = $('#preview-new-discussion');
  title_field = $('#discussion_title');
  preview_title = $('#preview-title');
  title_field.change -> preview_title.html(title_field.val())
  preview_button.click (event) ->
    preview.toggle 0, () -> preview_button.toggleClass('active')
    preview_title.toggle()

  # toggle formatting buttons on and off
  button_bar = $('#wmd-button-bar-new-discussion');
  formatting_button = $('#discussion-formatting')
  formatting_button.click (event) ->
    button_bar.toggle 0, () -> formatting_button.toggleClass('active')
    $('#toolbar .tooltip').toggle()

MarkdownSetup.start_new_motion_editor = () ->
  editor4 = new Markdown.Editor(MarkdownSetup.converter, '-new-motion', {handler: MarkdownSetup.showHelp});
  editor4.run();

  # toggle preview on and off
  preview = $('#wmd-preview-new-motion');
  preview_button = $('#preview-new-motion');
  title_field = $('#motion_name');
  preview_title = $('#preview-title');
  title_field.change -> preview_title.html(title_field.val())
  preview_button.click (event) ->
    preview.toggle 0, () -> preview_button.toggleClass('active')
    preview_title.toggle()

  # toggle formatting buttons on and off
  button_bar = $('#wmd-button-bar-new-motion');
  formatting_button = $('#motion-formatting')
  formatting_button.click (event) ->
    button_bar.toggle 0, () -> formatting_button.toggleClass('active')
    $('#toolbar .tooltip').toggle()

  # tooltips
  formatting_button.tooltip(placement: 'bottom')

MarkdownSetup.render_markdown = (scope = 'body') ->
  # 0. for each element marked for rendering:
  $(scope + ' .js-render-as-markdown').each ->
        # 5. replace the markdown formatted content with HTML
    $(this).html MarkdownSetup.converter.
        # 4. convert it to HTML
      makeHtml($(this).
        # 1. grab the content of this element
        text().
        # 2. remove leading whitespace
        replace(/^\s+/, "").
        # 3. remove html whitespace entity inserted by haml preserve function
        replace(/&#x000A;+/g, ""))
