<script lang="coffee">
import Records from '@/shared/services/records'
import { exact } from '@/shared/helpers/format_time'
import { parseISO } from 'date-fns'
import { reject, map, parseInt } from 'lodash'

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
      return '' unless @version && @version.objectChanges && @version.objectChanges[@bodyField]
      if @model[@bodyField+"Format"] == "md"
        @version.objectChanges[@bodyField].map (val) -> marked(val || '')
      else
        @version.objectChanges[@bodyField]

    titleChanges: ->
      (@version.objectChanges || {}).title

    bodyLabel: ->
      switch @model.constructor.singular
        when "comment" then "activity_card.comment"
        when "stance" then "poll_common.reason"
        when "discussion" then "discussion_form.context_label"
        when "poll" then "poll_common.details"
        when "outcome" then "poll_common.statement"

    objectKeys: ->
      excl = switch @model.constructor.singular
        when "comment" then ['body', 'body_format']
        when "stance" then ['reason', 'reason_format']
        when "discussion" then ['title', 'description', 'description_format']
        when "poll" then ['title', 'details', 'details_format']
        when "outcome" then ['statement', 'statement_format']
      reject Object.keys(@version.objectChanges || {}), (key) -> excl.includes(key)

    otherFields: ->
      @objectKeys.map (key) =>
        vals = @version.objectChanges[key].map (v) =>
          if v
            (key.match(/_at$/) && exact(parseISO(v))) || v
          else
            @$t('common.empty')
        {key: key, was: vals[0], now: vals[1]}

    stanceChoices: ->
      if @model.constructor.singular == "stance" &&
         @version.objectChanges['option_scores']
        was = @version.objectChanges['option_scores'][0]
        now = @version.objectChanges['option_scores'][1]
        wasChoices = map was, (score, pollOptionId) =>
          option = Records.pollOptions.find(parseInt(pollOptionId))
          # option = @model.poll().pollOptions().find( (o) -> o.id == parseInt(pollOptionId) )
          {
            name: option.optionName()
            color: option.color
            score: score
          }
        nowChoices = map now, (score, pollOptionId) =>
          # option = @model.poll().pollOptions().find( (o) -> o.id == parseInt(pollOptionId) )
          option = Records.pollOptions.find(parseInt(pollOptionId))
          {
            name: option.optionName()
            color: option.color
            score: score
          }
        {was: wasChoices, now: nowChoices}
      else
        false

    labelFor: (field) ->
      # setup a case soon
      field

</script>

<template lang="pug">

.revision-history-content
  .mb-3(v-if="titleChanges")
    v-label(v-t="'discussion_form.title_label'")
    html-diff.headline(:before="titleChanges[0]" :after="titleChanges[1]")

  .mb-3(v-if="!stanceChoices && otherFields.length")
    v-simple-table(dense)
      thead
        tr
          th(v-t="'revision_history_modal.field'")
          th(v-t="'revision_history_modal.before'")
          th(v-t="'revision_history_modal.after'")
      tbody
        tr(v-for="field in otherFields")
          td {{field.key}}
          td {{field.was}}
          td {{field.now}}

  .mb-3(v-if="stanceChoices")
    .text-secondary(v-t="'revision_history_modal.before'")
    v-simple-table.mb-4(dense)
      tr(v-for="choice in stanceChoices.was")
        td(:style="'border-left: 2px solid '+choice.color") {{choice.name}}
        td {{choice.score}}
    .text-secondary(v-t="'revision_history_modal.after'")
    v-simple-table.mb-4(dense)
      tr(v-for="choice in stanceChoices.now")
        td(:style="'border-left: 2px solid '+choice.color") {{choice.name}}
        td {{choice.score}}
  .mb-3(v-if="bodyChanges")
    v-label(v-t="bodyLabel")
    html-diff.lmo-markdown-wrapper(:before="bodyChanges[0]" :after="bodyChanges[1]")

</template>
