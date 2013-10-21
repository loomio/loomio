window.ClientsideMarkdown ||=
  render: (node)->
    converter = new Markdown.Converter()
    converter.autoNewLine = true;
    $(node.find('.js-markdown')).each ->
      # stip the leading whitespace, then strip the whitespace inserted by haml's preserve function
      $(this).html converter.makeHtml($(this).text().replace(/^\s+/, "").replace(/&#x000A;+/g, ""))

$ ->
  cm = ClientsideMarkdown.render($('body'))
