<script lang="coffee">
import Session from '@/shared/services/session'
import { submitForm } from '@/shared/helpers/form'

export default
  props:
    model: Object
    close: Function
  data: ->
    volumeLevels: ["loud", "normal", "quiet"]
    isDisabled: false
  mounted: ->
    @submit = submitForm @, @model,
      submitFn: (model) ->
        model.saveVolume(@buh.volume, @applyToAll, @setDefault)
      flashSuccess: @flashTranslation
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
      "#{@translateKey(key)}.messages.#{@buh.volume}"
  computed:
    defaultVolume: ->
      switch @model.constructor.singular
        when 'discussion' then @model.volume()
        when 'membership' then @model.volume
        when 'user'       then @model.defaultMembershipVolume
    buh: ->
      volume: @defaultVolume
</script>
<template lang="pug">
v-card.change-volume-form
  form(ng-submit='submit()')
    .lmo-disabled-form(v-show='isDisabled')
    v-card-title
      .md-toolbar-tools.lmo-flex__space-between
        h1.lmo-h1.change-volume-form__title(v-t="{ path: translateKey() + '.title', args: { title: model.title || model.groupName } }")
        dismiss-modal-button(:close="close")
    .md-dialog-content
      v-radio-group.md-body-1(v-model='buh.volume')
        v-radio.md-checkbox--with-summary(v-for='level in volumeLevels', :value='level', :key="'volume-#{level}'")
          span(v-t="'change_volume_form.#{level}_label'")
          .change-volume-form__description(v-t="'#{translateKey()}.#{level}_description'")
        v-checkbox#apply-to-all.change-volume-form__apply-to-all(v-model='applyToAll')
          label.change-volume-form__apply-to-all-label(for='apply-to-all', v-t="'#{translateKey().apply_to_all}'")
      v-card-actions.lmo-md-actions
        v-btn.change-volume-form__cancel(type='button', v-t="'common.action.cancel'", @click='close()')
        v-btn.md-raised.md-primary.change-volume-form__submit(type='submit', :disabled='isDisabled', v-t="'common.action.update'")
</template>
