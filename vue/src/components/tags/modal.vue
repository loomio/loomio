<script lang="js">
import Records        from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import AppConfig      from '@/shared/services/app_config';

export default {
  props: {
    tag: {
      type: Object,
      required: true
    },
    close: Function
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

    v-btn-toggle.tag-colors.flex-wrap(rounded v-model="tag.color")
      v-btn(size="x-small" icon v-for="color in tag.constructor.colors" :key="color" :value="color" :color="color")
        common-icon(size="large" name="mdiTag" :color="tag.color == color ? '#333' : color")
  v-card-actions
    v-btn(v-if="tag.id", @click="deleteTag" :disabled="loading")
      span(v-t="'common.action.delete'")
    v-spacer
    v-btn.tag-form__submit(:disabled="!tag.name" variant="elevated" color="primary" @click="submit" :loading="loading")
      span(v-t="'common.action.save'")
</template>

<style lang="sass">

.color-swatch input
  opacity: 0 !important
  pointer-events: none !important

.color-swatch label
  overflow: hidden
  border: 2px solid #ddd
  border-radius: 28px
  display: block
  width: 28px
  height: 28px

.color-swatch input:checked + label
  border: 2px solid #777
</style>
