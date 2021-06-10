<script lang="coffee">
import { NodeViewWrapper, nodeViewProps, NodeViewContent } from '@tiptap/vue-2'

export default
  components: { NodeViewWrapper, NodeViewContent }

  props: nodeViewProps

  data: ->
    modal: false
    date: @node.attrs.dueOn
    checked: @node.attrs.checked

  methods:
    labelClicked: -> console.log 'label clicked'
    onCheckboxChange: (val) ->
      @updateAttributes({ checked: val.target.checked })

</script>

<template lang="pug">
node-view-wrapper.d-flex.align-center(as="li")
  input(contenteditable="false" draggable="true" data-drag-handle type="checkbox" :checked="checked" @change="onCheckboxChange")

  //- v-checkbox
  //- div(class="content") this is some task item content
  node-view-content(class="task-item-text")
  v-dialog(ref="dialog" v-model="modal" :return-value.sync="date" persistent width="290px")
    template(v-slot:activator="{ on, attrs }")
      v-chip(v-if="date") {{date}}
      v-btn(v-else icon v-bind="attrs" v-on="on")
        v-icon mdi-calendar
    v-date-picker(v-model="date" scrollable)
      v-spacer
      v-btn(text color="primary" @click="date = null; modal = false" v-t="$t('common.action.clear')")
      v-btn(text color="primary" @click="$refs.dialog.save(date)" v-t="$t('common.action.ok')")

</template>

<style lang="sass">
</style>
