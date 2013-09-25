help = () ->
  $('#wmd-help').modal('toggle')
  return false

start_editor = () ->
  converter = Markdown.getSanitizingConverter();
  converter.autoNewLine = true;
  editor = new Markdown.Editor(converter, '', {handler: help});
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

render_markdown = () ->
  converter = Markdown.getSanitizingConverter();
  converter.autoNewLine = true;
  $('.js-render-as-markdown').each ->
    $(this).replaceWith converter.makeHtml($(this).text().
              replace(/^\s+/, "").
              replace(/&#x000A;+/g, ""))

