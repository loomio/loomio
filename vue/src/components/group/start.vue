<script lang="coffee">
import Records       from '@/shared/services/records'
import LmoUrlService from '@/shared/services/lmo_url_service'
import { applySequence } from '@/shared/helpers/apply'

export default
  props:
    group: Object
    close: Function
  data: ->
    dgroup: @group.clone()
    announcement: {}
    dcurrentStep: "create"
  methods:
    completeGroupCreation: (group) ->
      @announcement = Records.announcements.buildFromModel(group)
      @dcurrentStep = "announce"
  # created: ->
  #   applySequence @,
  #     steps: =>
  #       if @group.isNew()
  #         ['create', 'announce']
  #       else
  #         ['create']
  #     createComplete: (_, group) =>
  #       # @announcement = Records.announcements.buildFromModel(group)
  #       # LmoUrlService.goTo LmoUrlService.group(group)
</script>

<template lang="pug">
v-card.group-modal
  // <div v-show="isDisabled" class="lmo-disabled-form"></div>
  v-card-title
    v-layout(justify-space-between style="align-items: center")
      v-icon mdi-account-multiple
      .group-form__group-title(v-if="dcurrentStep == 'create'")
        h1.headline(v-if='dgroup.isNew() && dgroup.parentId', v-t="'group_form.start_subgroup_heading'")
        h1.headline(v-if='dgroup.isNew() && !dgroup.parentId', v-t="'group_form.start_group_heading'")
        h1.headline(v-if='!dgroup.isNew()', v-t="'group_form.edit_group_heading'")
      .group-form__invitation-title(v-if="dcurrentStep == 'announce'")
        h1.headline(v-t="'announcement.form.group_announced.title'")
      dismiss-modal-button(:close='close')
  v-card-text.md-body-1
    group-form(v-if="dcurrentStep == 'create'", :group='dgroup', :modal='true')
    announcement-form.animated(v-if="dcurrentStep == 'announce'", :announcement='announcement')
    // <dialog_scroll_indicator></dialog_scroll_indicator>
  v-card-actions
    group-form-actions(v-if="dcurrentStep == 'create'", :group='dgroup', :successFn='completeGroupCreation')
    // <announcement_form_actions v-if="dcurrentStep = 'announce'" :announcement="announcement"></announcement_form_actions>
</template>
