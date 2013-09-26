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

MarkdownSetup.rendererRequired = () ->
  $('.discussions.show').length > 0 || $('.groups.show').length > 0 || $('.discussions.new').length > 0

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

MarkdownSetup.start_new_discussion_editor = () ->
  editor3 = new Markdown.Editor(MarkdownSetup.converter, '-new-discussion', {handler: MarkdownSetup.showHelp});
  editor3.run();

  # toggle preview on and off
  preview = $('#wmd-preview-new-discussion');
  preview_button = $('#preview-new-discussion');
  preview_button.click (event) ->
    preview.toggle 0, () -> preview_button.toggleClass('active')
    $('#preview-title').html($('#discussion_title').val()).toggle()

MarkdownSetup.render_markdown = (scope = 'body') ->
  $(scope + ' .js-render-as-markdown').each ->
    $(this).html MarkdownSetup.converter.makeHtml($(this).text().
              replace(/^\s+/, "").
              replace(/&#x000A;+/g, ""))
