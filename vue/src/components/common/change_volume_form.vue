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
    volumeLevels: ["loud", "normal", "quiet"]
    isDisabled: false
    applyToAll: if @model.isA('user') then true else false
    volume: if @model.isA('user') then "" else @defaultVolume()
  mounted: ->
    @submit = submitForm @, @model,
      submitFn: (model) =>
        model.saveVolume(@volume, @applyToAll)
      flashSuccess: 'change_volume_form.saved'
      successCallback: => @closeModal()
  methods:
    translateKey: (key) ->
      if @model.isA('user')
        "change_volume_form.all_groups"
      else
        "change_volume_form.#{key || @model.constructor.singular}"

    defaultVolume: ->
      switch @model.constructor.singular
        when 'discussion' then @model.volume()
        when 'membership' then @model.volume
        when 'user'       then @model.defaultMembershipVolume
    groupName: ->
      if @model.groupName
        @model.groupName()
      else
        ''
    openGroupVolumeModal: ->
      @closeModal()
      setTimeout => GroupService.actions(@model.group(), @).change_volume.perform()

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
      v-radio-group(v-model='volume')
        v-radio(v-for='level in volumeLevels', :value='level', :class="'volume-' + level", :key="'volume-' + level", :label="$t(translateKey() + '.' + level + '_description')")
      p(v-if="model.isA('discussion')")
        span(v-t="'change_volume_form.discussion.only_this_thread'")
        space
        a(@click="openGroupVolumeModal()" v-t="'change_volume_form.discussion.group'")
      v-checkbox#apply-to-all.change-volume-form__apply-to-all(v-if="model.isA('membership')" v-model='applyToAll', :label="$t('change_volume_form.membership.apply_to_organization', { organization: model.group().parentOrSelf().name })")
    v-card-actions
      v-spacer
      v-btn.change-volume-form__submit(type='button', :disabled='!volume', v-t="'common.action.update'" @click='submit()' color="primary")
</template>
