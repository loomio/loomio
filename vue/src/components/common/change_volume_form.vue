<script lang="coffee">
import Session from '@/shared/services/session'
import { submitForm } from '@/shared/helpers/form'
import ChangeVolumeModalMixin from '@/mixins/change_volume_modal'
import GroupService from '@/shared/services/group_service'
export default
  mixins: [ChangeVolumeModalMixin]
  props:
    model: Object
    close: Function
    showClose:
      default: true
      type: Boolean
  data: ->
    includeInCatchUp: true
    volumeLevels: ["loud", "normal", "quiet"]
    isDisabled: false
    applyToAll: @defaultApplyToAll()
    volume: @defaultVolume()

  mounted: ->
    @submit = submitForm @, @model,
      submitFn: (model) =>
        model.saveVolume(@volume, @applyToAll)
      flashSuccess: 'change_volume_form.saved'
      successCallback: => @closeModal()

  computed:
    formChanged: ->
      (@volume != @defaultVolume()) || (@applyToAll != @defaultApplyToAll())

  methods:
    defaultApplyToAll: ->
      if @model.isA('user') then true else false

    defaultVolume: ->
      switch @model.constructor.singular
        when 'discussion' then @model.volume()
        when 'membership' then @model.volume
        when 'user'       then null

    labelFor: (volume) ->
      @$t("change_volume_form.simple.#{volume}")+' - '+@$t("change_volume_form.simple.#{volume}_explain")

    translateKey: (key) ->
      if @model.isA('user')
        "change_volume_form.all_groups"
      else
        "change_volume_form.#{key || @model.constructor.singular}"


    groupName: ->
      if @model.groupName
        @model.groupName()
      else
        ''
    openGroupVolumeModal: ->
      @closeModal()
      setTimeout => GroupService.actions(@model.group(), @).change_volume.perform()

    openUserPreferences: ->
      @closeModal()
      @$router.push('/email_preferences')

</script>
<template lang="pug">
v-card.change-volume-form
  form
    submit-overlay(:value='model.processing')
    v-card-title
      h1.headline.change-volume-form__title(v-t="{ path: translateKey() + '.title', args: { title: model.title || model.name || groupName() } }")
      v-spacer
      dismiss-modal-button(v-if="showClose" :close="close")
    v-card-text
      p.mt-4(v-if="model.isA('membership')")
      v-radio-group(hide-details v-model='volume')
        v-radio.volume-loud(value='loud' :label="labelFor('loud')")
        v-radio.volume-normal(value='normal' :label="labelFor('normal')")
        v-radio.volume-quiet(value='quiet' :label="labelFor('quiet')")

      div(v-if="model.isA('membership') && model.group().parentOrSelf().hasSubgroups()")
        v-checkbox#apply-to-all.mb-4(v-if="model.isA('membership')" v-model='applyToAll', :label="$t('change_volume_form.membership.apply_to_organization', { organization: model.group().parentOrSelf().name })" hide-details)

      p.mt-4(v-if="model.isA('discussion')")
        a(@click="openGroupVolumeModal()" v-t="'change_volume_form.discussion.group'")
      p.mt-4(v-if="model.isA('membership')")
        a(@click="openUserPreferences()") Change user email preferences
    v-card-actions(align-center)
      v-spacer
      v-btn.change-volume-form__submit(type='button', :disabled='!formChanged', v-t="'common.action.update'" @click='submit()' color="primary")
</template>
