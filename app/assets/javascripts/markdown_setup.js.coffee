window.MarkdownSetup = {}

MarkdownSetup.init = () ->
  if MarkdownSetup.required()
    MarkdownSetup.converter = Markdown.getSanitizingConverter();
    MarkdownSetup.converter.autoNewLine = true;
    MarkdownSetup.start_editor()
    MarkdownSetup.render_markdown()

MarkdownSetup.required = () ->
  $('.discussions.show').length > 0

MarkdownSetup.help = () ->
  $('#wmd-help').modal('toggle')
  return false

MarkdownSetup.start_editor = () ->
  editor = new Markdown.Editor(MarkdownSetup.converter, '', {handler: help});
  editor.run();

  # toggle comment preview on and off
  preview = $('#wmd-preview');
  preview_button = $('#preview-comment');
  preview_button.click (event) ->
    preview.toggle 0, () -> preview_button.toggleClass('active')

  # toggle formatting buttons on and off
  button_bar = $('#wmd-button-bar');
  formatting_button = $('#comment-formatting')
  formatting_button.click (event) ->
    button_bar.toggle 0, () -> formatting_button.toggleClass('active')

MarkdownSetup.render_markdown = () ->
  $('.js-render-as-markdown').each ->
    $(this).replaceWith MarkdownSetup.converter.makeHtml($(this).text().
              replace(/^\s+/, "").
              replace(/&#x000A;+/g, ""))

