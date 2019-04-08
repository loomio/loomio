<script lang="coffee">
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import { submitForm } from '@/shared/helpers/form'

export default
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

<template lang="pug">
v-card.description-card(aria-labelledby='description-card-title')
  v-subheader(v-t="'description_card.title'")
  v-card-text
    .description-card__placeholder.lmo-hint-text(v-t="'description_card.placeholder'", v-if='!group.description')
    .description-card__text.lmo-markdown-wrapper(v-if="group.descriptionFormat == 'md'" v-marked='group.description')
    .description-card__text.lmo-markdown-wrapper(v-if="group.descriptionFormat == 'html'" v-html='group.description')
    attachment-list(:attachments="group.attachments")
    document-list(:model='group')
    .lmo-md-action
      action-dock(:model='group', :actions='actions')
</template>

<style lang="scss">

@import 'app.scss';

.description-card__documents-link {
  @include cardMinorAction;
  margin: 0 0 0 4px;
  line-height: 32px;
}
</style>
