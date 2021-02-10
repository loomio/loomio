<script lang="coffee">
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import AppConfig      from '@/shared/services/app_config'
import VuetifyColors  from 'vuetify/lib/util/colors'

export default
  props:
    tag:
      type: Object
      required: true
    close: Function

  data: ->
    loading: false
    colors: Object.keys(VuetifyColors).map (name) -> VuetifyColors[name]['base']

  methods:
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
    p color {{tag.color}}
    .tag-colors.d-flex
      span.color-swatch(v-for="color in colors" :key="color")
        input(:id="color" v-model="tag.color" :value="color" type="radio")
        label(:for="color" :style="{'background-color': color, color: color}") {{color}}
  v-card-actions
    v-spacer
    v-btn.tag-form__submit(color="primary" @click="submit" v-t="'common.action.save'" :loading="loading")
</template>

<style lang="sass">
.color-swatch input
  opacity: 0 !important
  pointer-events: none !important

.color-swatch label
  overflow: hidden
  border: 1px solid #eee
  border-radius: 25px
  display: block
  width: 25px
  height: 25px

.color-swatch input:checked + label
  border: 1px solid black
</style>
