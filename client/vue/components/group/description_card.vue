<script lang="coffee">
Records        = require 'shared/services/records'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'

{ submitForm } = require 'shared/helpers/form'

module.exports =
  props:
    group: Object

  created: ->
    @actions = [
      name: 'edit_group'
      icon: 'mdi-pencil'
      canPerform: =>
        AbilityService.canEditGroup(@group)
      perform:    => ModalService.open 'GroupModal', group: => @group
    ,
      name: 'add_resource'
      icon: 'mdi-attachment'
      canPerform: =>
        AbilityService.canAdministerGroup(@group)
      perform:    => ModalService.open 'DocumentModal', doc: =>
        Records.documents.build
          modelId:   @group.id
          modelType: 'Group'
    ]
</script>

<template>
  <v-card
    aria-labelledby="description-card-title"
    class="description-card"
  >
    <v-card-text>
      <h2
        v-t="'description_card.title'"
        class="description-card__title lmo-card-heading"
      ></h2>
      <div
        v-t="'description_card.placeholder'"
        v-if="!group.description"
        class="description-card__placeholder lmo-hint-text"
      ></div>
      <div
        v-marked="group.description"
        class="description-card__text lmo-markdown-wrapper"
      ></div>
      <document-list
        :model="group"
        placeholder="document.list.no_group_documents"
      ></document-list>
      <div
        class="lmo-md-action"
      >
        <action-dock
          :model="group"
          :actions="actions"
        ></action-dock>
      </div>
    </v-card-text>
  </v-card>
</template>

<style lang="scss">

@import 'app.scss';

.description-card__documents-link {
  @include cardMinorAction;
  margin: 0 0 0 4px;
  line-height: 32px;
}
</style>
