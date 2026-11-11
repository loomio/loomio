<script lang="js">
import { defineAsyncComponent } from 'vue'

export default {
  emits: ['draft-text'],
  props: {
    focusId: String,
    model: Object,
    field: String,
    label: String,
    placeholder: String,
    maxLength: Number,
    autofocus: Boolean,
    allowMentions: {
      type: Boolean,
      default: true
    }
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
  .lmo-textarea(:class="{ 'pt-4': label }")
    collab-editor(
      v-if="format == 'html'"
      :focus-id="focusId"
      :model='model'
      :field='field'
      :label='label'
      :placeholder="placeholder"
      :maxLength="maxLength"
      :autofocus="autofocus"
      :allow-mentions="allowMentions"
      @draft-text="$emit('draft-text', $event)"
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
      :allow-mentions="allowMentions"
    )
      template(v-for="(_, name) in $slots" v-slot:[name]="slotProps")
        slot(v-if="slotProps" :name="name" v-bind="slotProps")
        slot(v-else :name="name")

</template>
