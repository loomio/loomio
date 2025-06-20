<script lang="js">
import { defineAsyncComponent } from 'vue'

export default {
  props: {
    focusId: String,
    model: Object,
    field: String,
    label: String,
    placeholder: String,
    maxLength: Number,
    autofocus: Boolean,
    shouldReset: Boolean
  },

  components: {
    'md-editor': defineAsyncComponent(() => import('@/components/lmo_textarea/md_editor.vue')),
    'collab-editor': defineAsyncComponent(() => import('@/components/lmo_textarea/collab_editor.vue'))
  },

  computed: {
    format() {
      return this.model[`${this.field}Format`];
    }
  }
};
</script>

<template lang="pug">
div
  .lmo-textarea
    collab-editor(
      v-if="format == 'html'"
      :focus-id="focusId"
      :model='model'
      :field='field'
      :label='label'
      :placeholder="placeholder"
      :maxLength="maxLength"
      :autofocus="autofocus"
      :shouldReset="shouldReset"
    )
      template(v-for="(_, name) in $slots" v-slot:[name]="slotProps")
        slot(v-if="slotProps" :name="name" v-bind="slotProps")
        slot(v-else :name="name")
    md-editor(
      v-if="format == 'md'"
      :focus-id="focusId"
      :model='model'
      :field='field'
      :label='label'
      :placeholder="placeholder"
      :maxLength="maxLength"
      :autofocus="autofocus"
      :shouldReset="shouldReset"
    )
      template(v-for="(_, name) in $slots" v-slot:[name]="slotProps")
        slot(v-if="slotProps" :name="name" v-bind="slotProps")
        slot(v-else :name="name")

</template>
