<style lang="scss">
</style>

<script lang="coffee">
Records       = require 'shared/services/records'
LmoUrlService = require 'shared/services/lmo_url_service'

{ applySequence } = require 'shared/helpers/apply'

module.exports =
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

<template>
  <v-card class="group-modal">
    <!-- <div v-show="isDisabled" class="lmo-disabled-form"></div> -->
    <v-card-title>
      <div class="md-toolbar-tools lmo-flex__space-between">
        <i class="mdi mdi-account-multiple"></i>
        <div class="group-form__title">
          <div v-if="dcurrentStep == 'create'" class="group-form__group-title">
            <h1 v-if="dgroup.isNew() && dgroup.parentId" v-t="'group_form.start_subgroup_heading'" class="lmo-h1"></h1>
            <h1 v-if="dgroup.isNew() && !dgroup.parentId" v-t="'group_form.start_group_heading'" class="lmo-h1"></h1>
            <h1 v-if="!dgroup.isNew()" v-t="'group_form.edit_group_heading'" class="lmo-h1"></h1>
          </div>
          <div v-if="dcurrentStep == 'announce'" class="group-form__invitation-title">
            <h1 v-t="'announcement.form.group_announced.title'" class="lmo-h1"></h1>
          </div>
        </div>
        <dismiss-modal-button :close="close"></dismiss-modal-button>
      </div>
    </v-card-title>
    <v-card-text class="md-body-1 lmo-slide-animation">
      <group-form v-if="dcurrentStep == 'create'" :group="dgroup" :modal="true" class="animated"></group-form>
      <announcement-form v-if="dcurrentStep == 'announce'" :announcement="announcement" class="animated"></announcement-form>
      <!-- <dialog_scroll_indicator></dialog_scroll_indicator> -->
    </v-card-text>
    <v-card-actions>
      <group-form-actions v-if="dcurrentStep == 'create'" :group="dgroup" :successFn="completeGroupCreation"></group-form-actions>
      <!-- <announcement_form_actions v-if="dcurrentStep = 'announce'" :announcement="announcement"></announcement_form_actions> -->
    </v-card-actions>
  </v-card>
</template>
