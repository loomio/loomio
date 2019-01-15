Session        = require 'shared/services/session'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'
urlFor         = require 'vue/mixins/url_for'

module.exports =
  mixins: [urlFor]
  props:
    group: Object
    homePage: Object
    compact: Boolean
    discussion: Object
  created: ->
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
    canUploadPhotos: ->
      !_.isEmpty(@homePage) and AbilityService.canAdministerGroup(@group)
  template:
    """
    <div class="group-theme">
      <div class="group-theme__cover lmo-no-print">
        <div v-if="canUploadPhotos" class="group-theme__upload-photo">
          <button @click="openUploadCoverForm()" :title="$t('group_page.new_cover_photo')" class="lmo-flex lmo-flex__center"><i class="mdi mdi-camera mdi-24px"></i><span translate="group_page.new_photo" class="group-theme__upload-help-text"></span></button>
        </div>
      </div>
      <div v-if="compact" class="group-theme__header--compact">
        <div aria-hidden="true" class="group-theme__logo--compact">
          <a lmo-href-for="group"><img :src="group.logoUrl()" :alt="$t('group_page.group_logo')"></a>
        </div>
        <div aria-label="breadcrumb" role="navigation" class="group-theme__name--compact">
          <a v-if="group.isSubgroup()" lmo-href-for="group.parent()">{{group.parentName()}}</a>
          <span v-if="group.isSubgroup()">-</span>
          <a :href="urlFor(group)" aria-current="page">{{group.name}}</a>
          <span v-if="discussion">-</span>
          <a v-if="discussion" :href="urlFor(discussion)" aria-current="page">{{discussion.title}}</a>
        </div>
      </div>
      <div v-if="!compact" class="group-theme__header">
        <div :style="logoStyle" :alt="$t('group_page.group_logo')" class="group-theme__logo">
          <div v-if="canUploadPhotos" class="group-theme__upload-photo">
            <button @click="openUploadLogoForm()" :title="$t('group_page.new_group_logo')" class="lmo-flex lmo-flex__center">
            <i class="mdi mdi-camera mdi-24px"></i>
            <span v-t="'group_page.new_photo'" class="group-theme__upload-help-text"></span></button>
          </div>
        </div>
      <div class="group-theme__name-and-actions">
        <h1 aria-label="breadcrumb" role="navigation" class="lmo-h1 group-theme__name">
        <a v-if="group.isSubgroup()" :href="urlFor(group.parent())">{{group.parentName()}}</a>
        <span v-if="group.isSubgroup()">-</span>
        <a :href="urlFor(group)">{{group.name}}</a></h1>
          <div v-if="homePage" class="group-theme__actions">
            <join-group-button :group="group"></join-group-button>
            <!-- <outlet name="group-theme-actions" model="group"></outlet> -->
            <div v-if="canPerformActions" class="group-theme__member-actions">
                <!-- <outlet name="group-theme-member-actions" model="group"></outlet> -->
                <group-privacy-button :group="group"></group-privacy-button>
                <group-actions-dropdown :group="group"></group-actions-dropdown>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
