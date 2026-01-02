<script lang="js">
import { NodeViewWrapper, nodeViewProps, NodeViewContent } from '@tiptap/vue-3';
import { format, utcToZonedTime } from 'date-fns-tz';

export default
{
  components: { NodeViewWrapper, NodeViewContent },

  props: nodeViewProps,

  data() {
    return {
      modalOpen: false,
      date: null,
      remind: 0,
      checked: this.node.attrs.checked,
      reminders: [
        {title: this.$t('tasks.no_reminder'), value: null},
        {title: this.$t('tasks.on_due_date'), value: 0},
        {title: this.$t('tasks.1_day_before'), value: 1},
        {title: this.$t('tasks.2_day_before'), value: 2},
        {title: this.$t('tasks.3_day_before'), value: 3},
        {title: this.$t('tasks.7_day_before'), value: 7}
      ],
      mentioned: []
    };
  },

  methods: {
    findMentioned(node) {},
      // console.log node.toString()
      // if node.content
      //   if isArray(node.content)
      //     node.content.forEach (n) =>
      //       @findMentioned(n)
      //   else
      //     @findMentioned(node.content)
      //
      // if node.type == 'mention'
      //   @menitoned << node.attrs.id

    onCheckboxChange(val) {
      this.checked = !this.checked;
      this.updateAttributes({ checked: this.checked });
    },

    openModal() {
      this.findMentioned(this.node);
      this.date = this.node.attrs.dueOn ? new Date(this.node.attrs.dueOn) : new Date();
      this.remind = this.date ? (parseInt(this.node.attrs.remind) || null) : 0;
      this.modalOpen = true;
    },

    saveAndClose() {
      this.updateAttributes({dueOn: format(this.date, "yyyy-MM-dd"), remind: this.remind});
      this.modalOpen = false;
    },

    clearAndClose() {
      this.updateAttributes({dueOn: null, remind: null});
      this.modalOpen = false;
    }
  },

  computed: {
    isEmpty() { return this.node.toString() === "taskItem(paragraph)"; },
    hasMention() { return this.node.toString().includes('mention'); }
  }
};

</script>

<template lang="pug">
node-view-wrapper(as="li")
  v-checkbox-btn(contenteditable="false" color="accent" :ripple="false" type="checkbox" :value="checked" @click="onCheckboxChange")
  node-view-content(as="span" :class="{'task-item-text': true, 'task-item-is-empty': isEmpty}" :data-placeholder="$t('tasks.task_placeholder')")
  v-chip.ml-2(v-if="hasMention" contenteditable="false" color="primary" size="x-small" @click="openModal")
    | 📅
    span.ml-1(v-if="node.attrs.dueOn") {{node.attrs.dueOn}}
    span.ml-1(v-else v-t="'tasks.add_due_date'")
  v-dialog(contenteditable="false" ref="dialog" v-model="modalOpen" persistent width="340px")
    v-card(:title="$t('tasks.due_date')")
      template(v-slot:append)
        v-btn(icon variant="flat" @click="modalOpen = false")
          common-icon(name="mdi-close")
      v-date-picker(v-model="date" hide-header scrollable :show-current="false" :min="(new Date())")
      v-card-text
        v-select(v-model="remind" :label="$t('tasks.send_reminder')" :items="reminders")
      v-card-actions
        v-btn(variant="text" color="primary" @click="clearAndClose")
          span(v-t="'common.action.remove'")
        v-spacer
        v-btn(variant="elevated" color="primary" @click="saveAndClose" :disabled="!date")
          span(v-t="'common.action.ok'")
</template>

<style lang="sass">
.task-item-text.task-item-is-empty::before
  content: attr(data-placeholder)
  float: left
  color: #ced4da
  pointer-events: none
  height: 0

.v-theme--dark, .v-theme--darkBlue
  .task-item-text.task-item-is-empty::before
    color: rgba(255, 255, 255, 0.2)


</style>
