<script lang="coffee">
import { NodeViewWrapper, nodeViewProps, NodeViewContent } from '@tiptap/vue-2'
import { isArray } from 'lodash'
export default
  components: { NodeViewWrapper, NodeViewContent }

  props: nodeViewProps

  data: ->
    modalOpen: false
    date: null
    remind: 0
    checked: @node.attrs.checked
    reminders: [
      {text: @$t('tasks.no_reminder'), value: null}
      {text: @$t('tasks.on_due_date'), value: 0}
      {text: @$t('tasks.1_day_before'), value: 1}
      {text: @$t('tasks.2_day_before'), value: 2}
      {text: @$t('tasks.3_day_before'), value: 3}
      {text: @$t('tasks.7_day_before'), value: 7}
    ]
    mentioned: []

  methods:
    findMentioned: (node) ->
      console.log node.toString()
      # if node.content
      #   if isArray(node.content)
      #     node.content.forEach (n) =>
      #       @findMentioned(n)
      #   else
      #     @findMentioned(node.content)
      #
      # if node.type == 'mention'
      #   @menitoned << node.attrs.id

    onCheckboxChange: (val) ->
      @checked = !@checked
      @updateAttributes({ checked: @checked })

    openModal: ->
      @findMentioned(@node)
      @date = @node.attrs.dueOn
      @remind = if @date then (parseInt(@node.attrs.remind) || null) else 0
      @modalOpen = true

    saveAndClose: ->
      @updateAttributes({dueOn: @date, remind: @remind})
      @modalOpen = false

    clearAndClose: ->
      @updateAttributes({dueOn: null, remind: null})
      @modalOpen = false

  computed:
    isEmpty: -> @node.toString() == "taskItem(paragraph)"
    hasMention: -> @node.toString().includes('mention')

</script>

<template lang="pug">
node-view-wrapper(as="li")
  //- input.flex-shrink-0(style="z-index: 2300" type="checkbox" :checked="node.attrs.checked" @change="onCheckboxChange")
  v-simple-checkbox(contenteditable="false" color="accent" :ripple="false" type="checkbox" :value="checked" @click="onCheckboxChange")
  node-view-content(as="span" :class="{'task-item-text': true, 'task-item-is-empty': isEmpty}" :data-placeholder="$t('tasks.task_placeholder')")
  v-chip.ml-2(v-if="hasMention" contenteditable="false" color="accent" x-small @click="openModal")
    | 📅
    span.ml-1(v-if="node.attrs.dueOn") {{node.attrs.dueOn}}
    span.ml-1(v-else v-t="'tasks.add_due_date'")
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
.task-item-text.task-item-is-empty::before
  content: attr(data-placeholder)
  float: left
  color: #ced4da
  pointer-events: none
  height: 0

</style>
