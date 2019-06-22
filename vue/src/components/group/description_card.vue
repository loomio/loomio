<script lang="coffee">
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import { submitForm } from '@/shared/helpers/form'
import ModalService   from '@/shared/services/modal_service'
import UrlFor         from '@/mixins/url_for'

export default
  mixins: [UrlFor]
  props:
    group: Object
  methods:
    openUploadCoverForm: ->
      ModalService.open 'CoverPhotoForm', group: => group

    openUploadLogoForm: ->
      ModalService.open 'LogoPhotoForm', group: => group

  computed:
    logoStyle: ->
      { 'background-image': "url(#{@group.logoUrl()})" }
    canPerformActions: ->
      AbilityService.isSiteAdmin() or AbilityService.canLeaveGroup(@group)
    canUploadPhotos: -> AbilityService.canAdministerGroup(@group)

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
.description-card(aria-labelledby='description-card-title')
  v-layout(mb-3)
    v-spacer
    join-group-button(:group='group')
    group-privacy-button(:group='group')
    group-actions-dropdown(:group='group')
  .description-card__placeholder.lmo-hint-text(v-t="'description_card.placeholder'", v-if='!group.description')
  .description-card__text.lmo-markdown-wrapper(v-if="group.descriptionFormat == 'md'" v-marked='group.description')
  .description-card__text.lmo-markdown-wrapper(v-if="group.descriptionFormat == 'html'" v-html='group.description')
  attachment-list(:attachments="group.attachments")
  document-list(:model='group')
  //- .group-theme__upload-photo(v-if='canUploadPhotos')
  //-   button.lmo-flex.lmo-flex__center(@click='openUploadCoverForm()', :title="$t('group_page.new_cover_photo')")
  //-     i.mdi.mdi-camera.mdi-24px
  //-     span.group-theme__upload-help-text.caption(translate='group_page.new_photo')
  //- .group-theme__upload-photo(v-if='canUploadPhotos')
  //-   button.lmo-flex.lmo-flex__center(@click='openUploadLogoForm()', :title="$t('group_page.new_group_logo')")
  //-     i.mdi.mdi-camera.mdi-24px
  //-     span.group-theme__upload-help-text(v-t="'group_page.new_photo'")

  //- .lmo-md-action
  //-   action-dock(:model='group', :actions='actions')
</template>
