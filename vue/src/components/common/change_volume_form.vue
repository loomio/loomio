<script lang="coffee">
import Session from '@/shared/services/session'
import { submitForm } from '@/shared/helpers/form'
import ChangeVolumeModalMixin from '@/mixins/change_volume_modal'

export default
  mixins: [ChangeVolumeModalMixin]
  props:
    model: Object
    close: Function
  data: ->
    volumeLevels: ["loud", "normal", "quiet"]
    isDisabled: false
    applyToAll: false
    volume: @defaultVolume()
  mounted: ->
    @submit = submitForm @, @model,
      submitFn: (model) =>
        model.saveVolume(@volume, @applyToAll, @setDefault)
      flashSuccess: @flashTranslation
      successCallback: => @closeModal()
  methods:
    translateKey: (key) ->
      "change_volume_form.#{key || @model.constructor.singular}"
    flashTranslation: ->
      key =
        if @applyToAll
          switch @model.constructor.singular
            when 'discussion' then 'membership'
            when 'membership' then 'all_groups'
            when 'user'       then 'all_groups'
        else
          @model.constructor.singular
      "#{@translateKey(key)}.messages.#{@volume}"
    defaultVolume: ->
      switch @model.constructor.singular
        when 'discussion' then @model.volume()
        when 'membership' then @model.volume
        when 'user'       then @model.defaultMembershipVolume
</script>
<template lang="pug">
v-card.change-volume-form
  form
    .lmo-disabled-form(v-show='isDisabled')
    v-card-title
      .md-toolbar-tools.lmo-flex__space-between
        h1.lmo-h1.change-volume-form__title(v-t="{ path: translateKey() + '.title', args: { title: model.title || model.groupName() } }")
        dismiss-modal-button(:close="close")
    v-card-text
      v-radio-group(v-model='volume')
        v-radio(v-for='level in volumeLevels', :value='level', :class="'volume-' + level", :key="'volume-' + level", :label="$t(translateKey() + '.' + level + '_description')")
        v-checkbox#apply-to-all.change-volume-form__apply-to-all(v-model='applyToAll', :label="$t(translateKey() + '.apply_to_all')")
      v-card-actions.lmo-md-actions
        v-btn.change-volume-form__cancel(type='button', v-t="'common.action.cancel'", @click='close()')
        v-btn.md-raised.md-primary.change-volume-form__submit(type='button', :disabled='isDisabled', v-t="'common.action.update'" @click='submit()')
</template>
