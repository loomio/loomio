<script lang="coffee">
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import AppConfig      from '@/shared/services/app_config'

export default
  props:
    tag:
      type: Object
      required: true
    close: Function

  data: ->
    loading: false
    destroying: false

  methods:
    deleteTag: ->
      EventBus.$emit 'openModal',
        component: 'ConfirmModal'
        props:
          confirm:
            submit: @tag.destroy
            text:
              title:    'loomio_tags.destroy_tag'
              helptext: 'loomio_tags.destroy_helptext'
              submit:   'common.action.delete'
              flash:    'loomio_tags.tag_destroyed'

    submit: ->
      @loading = true
      @tag.save().then =>
        @close()
      .finally =>
        @loading = false

</script>
<template lang="pug">
v-card.tags-modal
  v-card-title
    h1.headline(v-if="tag.id" tabindex="-1" v-t="'loomio_tags.modal_edit_title'")
    h1.headline(v-if="!tag.id" tabindex="-1" v-t="'loomio_tags.modal_title'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text
    v-text-field(v-model="tag.name" :label="$t('loomio_tags.name_label')" autofocus)
    validation-errors(:subject="tag" field="name")

    label(for="input-708" class="v-label caption" v-t="'loomio_tags.color_label'") Color

    .tag-colors.d-flex
      span.color-swatch(v-for="color in tag.constructor.colors" :key="color")
        input(:id="color" v-model="tag.color" :value="color" type="radio")
        label(:for="color" :style="{'background-color': color, color: color}") {{color}}
  v-card-actions
    v-btn(v-if="tag.id" @click="deleteTag" v-t="'common.action.delete'" :disabled="loading")
    v-spacer
    v-btn.tag-form__submit(color="primary" @click="submit" v-t="'common.action.save'" :loading="loading")
</template>

<style lang="sass">
.tag-colors
  flex-wrap: wrap

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
  border: 2px solid #000
</style>
