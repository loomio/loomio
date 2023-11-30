<script lang="js">
import RescueUnsavedEditsService from '@/shared/services/rescue_unsaved_edits_service';

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
    'md-editor': () => import('@/components/lmo_textarea/md_editor.vue'),
    'collab-editor': () => import('@/components/lmo_textarea/collab_editor.vue')
  },

  mounted() {
    RescueUnsavedEditsService.add(this.model);
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
  label.text-caption.v-label.v-label--active(style="color: var(--text-secondary)" aria-hidden="true") {{label}}
  .lmo-textarea.pb-1
    collab-editor(
      v-if="format == 'html'"
      :focus-id="focusId"
      :model='model'
      :field='field'
      :placeholder="placeholder"
      :maxLength="maxLength"
      :autofocus="autofocus"
      :shouldReset="shouldReset"
    )
      template(v-for="(_, name) in $scopedSlots", :slot="name" slot-scope="slotData")
        slot(:name="name", v-bind="slotData")
    md-editor(
      v-if="format == 'md'"
      :focus-id="focusId"
      :model='model'
      :field='field'
      :placeholder="placeholder"
      :maxLength="maxLength"
      :autofocus="autofocus"
      :shouldReset="shouldReset"
    )
      template(v-for="(_, name) in $scopedSlots", :slot="name", slot-scope="slotData")
        slot(:name="name" v-bind="slotData")

</template>
