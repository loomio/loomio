<script lang="js">
import Records        from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';

export default {
  props: {
    tag: {
      type: Object,
      required: true
    },
    close: Function,
    afterSave: Function
  },

  data() {
    return {
      loading: false,
      destroying: false
    };
  },

  computed: {
    title() {
      return this.tag.id ? 'loomio_tags.modal_edit_title' : 'loomio_tags.modal_title'
    }
  },
  methods: {
    deleteTag() {
      const tag = Records.tags.find(this.tag.id);
      EventBus.$emit('openModal', {
        component: 'ConfirmModal',
        props: {
          confirm: {
            submit: tag.destroy,
            text: {
              title:    'loomio_tags.destroy_tag',
              helptext: 'loomio_tags.destroy_helptext',
              submit:   'common.action.delete',
              flash:    'loomio_tags.tag_destroyed'
            }
          }
        }
      });
    },

    submit() {
      this.loading = true;
      this.tag.save().then(() => {
        return this.afterSave ? this.afterSave(this.tag) : null;
      }).then(() => {
        this.close();
      }).finally(() => {
        this.loading = false;
      });
    }
  }
};

</script>
<template lang="pug">
v-card.tags-modal(:title="$t(title)")
  template(v-slot:append)
    dismiss-modal-button(:close="close")
  v-card-text
    v-text-field.tags-modal__tag-name(v-model="tag.name" :label="$t('loomio_tags.name_label')" autofocus)
    validation-errors(:subject="tag" field="name")

    label(for="input-708" class="v-label caption" v-t="'loomio_tags.pick_a_color'")

    v-btn-toggle.tag-colors.flex-wrap(v-model="tag.color")
      v-btn.tag-color-button(icon size="small" variant="text" v-for="color in tag.constructor.colors" :key="color" :value="color" :title="color")
        span.tag-color-dot(:style="{backgroundColor: color}")
  v-card-actions
    v-btn.tag-form__delete(v-if="tag.id", @click="deleteTag" :disabled="loading")
      span(v-t="'common.action.delete'")
    v-spacer
    v-btn.tag-form__submit(:disabled="!tag.name" variant="elevated" color="primary" @click="submit" :loading="loading")
      span(v-t="'common.action.save'")
</template>

<style lang="sass">

.tag-colors
  gap: 4px

.tag-color-button
  min-width: 32px

.tag-color-dot
  border-radius: 50%
  display: inline-block
  height: 16px
  width: 16px

.tag-color-button.v-btn--active .tag-color-dot
  box-shadow: 0 0 0 2px rgb(var(--v-theme-surface)), 0 0 0 4px rgba(var(--v-theme-on-surface), 0.65)
</style>
