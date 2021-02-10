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
    color: @tag.color
    colors: '#F44336 #E91E63 #9C27B0 #2196F3'.split(' ')
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
    p {{tag.color}}
    span.color-swatch(v-for="color in colors" :key="color")
      input(:id="color" v-model="tag.color" :value="color" type="radio")
      label(:for="color") {{color}}
  v-card-actions
    v-spacer
    v-btn.tag-form__submit(color="primary" @click="submit" v-t="'common.action.save'" :loading="loading")
</template>

<style lang="sass">
.color-swatch
  input
    position: fixed !important
    opacity: 0 !important
    pointer-events: none !important

  label
    display: block
    width: 25px
    height: 25px
<style>
