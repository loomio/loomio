import marked from 'marked'
import {customRenderer, options} from '@/shared/helpers/marked.coffee'
import I18n from '@/i18n'
# import Turndown from 'turndown'

export convertToHtml = (model, field) ->
  marked.setOptions Object.assign({renderer: customRenderer()}, options)
  model["#{field}Format"] = "html"
  model[field] = marked(model[field] || '')

export convertToMd = (model, field) ->
  if confirm I18n.t('convert_to_markdown.body')
    import('turndown').then (Turndown) ->
      # import('turndown-plugin-gfm').then (TurndownPluginGfm) ->
      #   gfm = TurndownPluginGfm.gfm

      converter = Turndown.default
        headingStyle: 'atx'
        hr: '---'
        codeBlockStyle: 'fenced'

      converter.addRule 'mentions',
        filter: 'span'
        replacement: (content, node, options) ->
          return '@' + node.getAttribute('data-mention-id')

      model["#{field}Format"] = "md"
      model[field] = converter.turndown(model[field] || '')
