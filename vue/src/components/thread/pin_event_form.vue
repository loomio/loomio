<script lang="coffee">
import Flash from '@/shared/services/flash'
import { onError } from '@/shared/helpers/form'

export default
  props:
    event: Object
    close: Function

  data: ->
    title: null
    loading: false

  mounted: ->
    @title = (window.getSelection() && window.getSelection().toString()) || @event.pinnedTitle || @event.suggestedTitle()
    @$nextTick => @$refs.focus.focus()

  methods:
    submit: ->
      @loading = true
      @event.pin(@title)
      .then =>
        Flash.success('activity_card.event_pinned')
        @close()
      .catch onError(@event)

</script>
<template lang="pug">
v-card.pin-event-form
  v-card-title
    span(v-t="'pin_event_form.title'")
    v-spacer
    dismiss-modal-button(aria-hidden='true', :close='close')
  v-card-text
    v-form(@submit.prevent="submit()")
      v-text-field(:disabled="loading" ref="focus" v-model="title" :label="$t('pin_event_form.title_label')")
    p.caption(v-if="title && title.length == 0" v-t="'pin_event_form.hint'")
  v-card-actions
    v-spacer
    v-btn(color="primary" @click="submit()" :loading="loading" v-t="'common.action.save'")
</template>
