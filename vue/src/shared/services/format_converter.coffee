import marked from 'marked'
import {customRenderer, options} from '@/shared/helpers/marked.coffee'
marked.setOptions Object.assign({renderer: customRenderer()}, options)

export convertToHtml = (model, field) ->
  model["#{field}Format"] = "html"
  model[field] = marked(model[field] || '')

export convertToMd = (model, field) ->
  import("showdown").then (showdown) ->
    converter = new showdown.Converter()
    model["#{field}Format"] = "md"
    model[field] = converter.makeMarkdown(model[field] || '')
