<script lang="coffee">
import { NodeViewWrapper, nodeViewProps, NodeViewContent } from '@tiptap/vue-2'

export default
  components: { NodeViewWrapper, NodeViewContent }

  props: nodeViewProps

  data: ->
    modalOpen: false
    date: null

  methods:
    onCheckboxChange: (val) ->
      @updateAttributes({ checked: val.target.checked })

    setDueOn: (val) ->
      @updateAttributes({ dueOn: val })

</script>

<template lang="pug">
node-view-wrapper(as="li")
  input.flex-shrink-0(contenteditable="false" draggable="true" data-drag-handle type="checkbox" :checked="node.attrs.checked" @change="onCheckboxChange")
  node-view-content(as="span" class="task-item-text")
  v-chip.ml-2(color="accent" x-small @click="date = node.attrs.dueOn; modalOpen = true")
    v-icon mdi-calendar
    span.ml-1(v-if="node.attrs.dueOn") {{node.attrs.dueOn}}
  v-dialog(ref="dialog" v-model="modalOpen" persistent width="290px")
    v-date-picker(v-model="date" scrollable :show-current="false" :min="(new Date()).toISOString().substring(0,10)")
      v-spacer
      v-btn(text color="primary" @click="setDueOn(null); modalOpen = false" v-t="$t('common.action.clear')")
      v-btn(text color="primary" @click="setDueOn(date); modalOpen = false" v-t="$t('common.action.ok')")
</template>

<style lang="sass">
</style>
