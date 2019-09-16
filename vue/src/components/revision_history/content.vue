<script lang="coffee">
import Records from '@/shared/services/records'
import { exact } from '@/shared/helpers/format_time'
import { parseISO } from 'date-fns'

import marked from 'marked'
import {customRenderer, options} from '@/shared/helpers/marked.coffee'
marked.setOptions Object.assign({renderer: customRenderer()}, options)

export default
  props:
    model: Object
    version: Object

  methods:
    exact: exact

  computed:
    modelKind: -> @model.constructor.singular

    bodyField: ->
      switch @model.constructor.singular
        when "comment" then "body"
        when "stance" then "reason"
        when "discussion" then "description"
        when "poll" then "details"
        when "outcome" then "statement"

    bodyChanges: ->
      return unless @version.objectChanges[@bodyField]
      if @model[@bodyField+"Format"] == "md"
        @version.objectChanges[@bodyField].map (val) -> marked(val || '')
      else
        @version.objectChanges[@bodyField]

    titleChanges: ->
      @version.objectChanges.title

    bodyLabel: ->
      switch @model.constructor.singular
        when "comment" then "activity_card.comment"
        when "stance" then "poll_common.reason"
        when "discussion" then "discussion_form.context_label"
        when "poll" then "poll_common.details"
        when "outcome" then "poll_common.statement"

    closingAtChanges: ->
      if @version.objectChanges.closing_at
        @version.objectChanges.closing_at.map (iso) ->
          exact(parseISO(iso)) if iso

</script>

<template lang="pug">

.revision-history-content
  .mb-3(v-if="titleChanges")
    v-label(v-t="'discussion_form.title_label'")
    html-diff.headline(:before="titleChanges[0]" :after="titleChanges[1]")

  .mb-3(v-if="closingAtChanges")
    v-label(v-t="'poll_common_closing_at_field.closing'")
    p(v-t="{path: 'revision_history_modal.closing_at_changed', args: {time: closingAtChanges[1]}}")

  .mb-3(v-if="bodyChanges")
    v-label(v-t="bodyLabel")
    html-diff.lmo-markdown-wrapper(:before="bodyChanges[0]" :after="bodyChanges[1]")

</template>
