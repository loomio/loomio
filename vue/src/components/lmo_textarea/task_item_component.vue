<script lang="coffee">
import { NodeViewWrapper, nodeViewProps, NodeViewContent } from '@tiptap/vue-2'

export default
  components: { NodeViewWrapper, NodeViewContent }

  props: nodeViewProps

  data: ->
    modalOpen: false
    date: null
    remind: 0
    reminders: [
      {text: 'No reminder', value: null}
      {text: 'On due date', value: 0}
      {text: @$t('tasks.1_day_before'), value: 1}
      {text: @$t('tasks.2_day_before'), value: 2}
      {text: @$t('tasks.3_day_before'), value: 3}
      {text: @$t('tasks.7_day_before'), value: 7}
    ]

  methods:
    onCheckboxChange: (val) ->
      @updateAttributes({ checked: val.target.checked })

    openModal: ->
      @date = @node.attrs.dueOn
      @remind = if @date then (parseInt(@node.attrs.remind) || null) else 0
      @modalOpen = true

    saveAndClose: ->
      @updateAttributes({dueOn: @date, remind: @remind})
      @modalOpen = false

    clearAndClose: ->
      @updateAttributes({dueOn: null, remind: null})
      @modalOpen = false

</script>

<template lang="pug">
node-view-wrapper(as="li")
  input.flex-shrink-0(contenteditable="false" type="checkbox" :checked="node.attrs.checked" @change="onCheckboxChange")
  node-view-content(as="span" class="task-item-text")
  v-chip.ml-2(contenteditable="false" color="accent" x-small @click="openModal")
    v-icon mdi-calendar
    span.ml-1(v-if="node.attrs.dueOn") {{node.attrs.dueOn}}
  v-dialog(contenteditable="false" ref="dialog" v-model="modalOpen" persistent width="290px")
    v-card
      v-card-title
        span(v-t="'tasks.due_date'")
        v-spacer
        v-btn(icon @click="modalOpen = false")
          v-icon mdi-close
      v-date-picker(v-model="date" no-title scrollable :show-current="false" :min="(new Date()).toISOString().substring(0,10)")
      v-card-text
        v-select(v-model="remind" :label="$t('tasks.send_reminder')" :items="reminders")
      v-card-actions
        v-btn(text color="primary" @click="clearAndClose" v-t="$t('common.action.remove')")
        v-spacer
        v-btn(text color="primary" @click="saveAndClose" v-t="$t('common.action.ok')" :disabled="!date")
</template>

<style lang="sass">
</style>
