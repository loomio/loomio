<script lang="coffee">
import Records from '@/shared/services/records'
import { exact } from '@/shared/helpers/format_time'

export default
  props:
    model: Object
    version: Object
  methods:
    diffType: (field_name) ->
      # depending on the model type we will have different kinds
      switch field_name
        when "body", "description", "title", "reason" then (if @version.changes[field_name][0] then "diff" else "original");
        when "group_id", "private" then "notice";

    noticeValues: (field_name) ->
      switch field_name
        when "group_id" then { name: Records.groups.find(@version.changes.group_id[1]).name}
        when "private" then { private: if @version.changes.private[1] then "private" else "public"}
        when "closing_at" then {time: exact(@version.changes.closing_at[1])}
</script>
<template lang="pug">
.revision-history-content
  .revision-history-content--markdown.text-diff(v-if='model.constructor.singular == "comment"', v-html='version.changes.body')
  .revision-history-content--markdown.text-diff(v-if='model.constructor.singular == "stance"', v-html='version.changes.reason')
  div(v-if='model.constructor.singular == "discussion"')
    revision-history-text-diff.revision-history-content--header(:before='version.changes.title[0]', :after='version.changes.title[1]')
    .revision-history-content--markdown.text-diff(v-html='version.changes.description')
    p.text-diff(v-if='version.changes.private && !version.isOriginal()')
      ins(v-t='{ path: "revision_history_modal.private_changed", args: { private: noticeValues("private") }}')
    p.text-diff(v-if='version.changes.group_id && !version.isOriginal()')
      ins(v-t='{ path: "revision_history_modal.group_id_changed", args: { name: noticeValues("group_id") }}')
  div(v-if='model.constructor.singular == "poll"')
    revision-history-text-diff.poll-common-card__title.revision-history-content--header(:before='version.changes.title[0]', :after='version.changes.title[1]')
    .revision-history-content--markdown.text-diff(v-html='version.changes.details')
    p.text-diff(v-if='version.changes.closing_at')
      ins(v-t='{ path: "revision_history_modal.closing_at_changed", args: { time: noticeValues("closing_at") }}')
</template>
<style lang="sass">
.revision-history-content
  margin-top: 16px

.revision-history-modal__version
  max-height: 440px
  overflow: auto

.revision-history-content--header
  display: block
  margin-bottom: 16px

.revision-history-content--markdown
  table.markdown
    width: 100%
  tr:not(:last-child) td
    padding-bottom: 16px
  td
    width: 50%
    &:first-child
      border-right: 1px solid #ccc
      padding-right: 8px
    &:last-child
      padding-left: 8px
</style>
