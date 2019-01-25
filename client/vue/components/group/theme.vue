<script lang="coffee">
Session        = require 'shared/services/session'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'
urlFor         = require 'vue/mixins/url_for'

import JoinGroupButton from 'vue/components/group/join_button.vue'

module.exports =
  components:
    JoinGroupButton: JoinGroupButton
  mixins: [urlFor]
  props:
    group: Object
    homePage: Boolean
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
</script>

<template>
<div class="group-theme">
  <div class="group-theme__cover lmo-no-print">
    <div v-if="canUploadPhotos" class="group-theme__upload-photo">
      <button @click="openUploadCoverForm()" :title="$t('group_page.new_cover_photo')" class="lmo-flex lmo-flex__center"><i class="mdi mdi-camera mdi-24px"></i><span translate="group_page.new_photo" class="group-theme__upload-help-text caption"></span></button>
    </div>
  </div>
  <div v-if="compact" class="group-theme__header--compact">
    <div aria-hidden="true" class="group-theme__logo--compact">
      <router-link :to="urlFor(group)"><img :src="group.logoUrl()" :alt="$t('group_page.group_logo')"></router-link>
    </div>
    <div aria-label="breadcrumb" role="navigation" class="group-theme__name--compact">
      <router-link v-if="group.isSubgroup()" :to="urlFor(group.parent())">{{group.parentName()}}</router-link>
      <span v-if="group.isSubgroup()">-</span>
      <router-link :to="urlFor(group)" aria-current="page">{{group.name}}</router-link>
      <span v-if="discussion">-</span>
      <router-link v-if="discussion" :to="urlFor(discussion)" aria-current="page">{{discussion.title}}</router-link>
    </div>
  </div>
  <div v-if="!compact" class="group-theme__header">
    <div :style="logoStyle" :alt="$t('group_page.group_logo')" class="group-theme__logo">
      <div v-if="canUploadPhotos" class="group-theme__upload-photo">
        <button @click="openUploadLogoForm()" :title="$t('group_page.new_group_logo')" class="lmo-flex lmo-flex__center">
          <i class="mdi mdi-camera mdi-24px"></i>
          <span v-t="'group_page.new_photo'" class="group-theme__upload-help-text"></span>
        </button>
      </div>
    </div>
    <div class="group-theme__name-and-actions">
      <h1 aria-label="breadcrumb" role="navigation" class="lmo-h1 group-theme__name">
        <router-link v-if="group.isSubgroup()" :to="urlFor(group.parent())">{{group.parentName()}}</router-link>
        <span v-if="group.isSubgroup()">-</span>
        <router-link :to="urlFor(group)">{{group.name}}</router-link>
      </h1>
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
</template>

<style lang="scss">
@import 'app.scss';
.group-theme{
  @include lmoRow;
  padding-top: 48px;
}

.group-theme__cover{
  position: absolute;
  left: 0;
  top: 0;
  width: 100%;
  height: 320px;
  z-index: $z-zero;
  &:hover .group-theme__upload-photo {
    button { background: $background-transparent-color; }
    .group-theme__upload-help-text { opacity: 1; }
  }
}

.group-theme__header{
  width: 100%;
  position: relative;
  min-height: 335px;
}

.group-theme__member-actions button{
  @include md-body-2;
}

.group-theme__header--compact {
  position: relative;
  margin: 215px 0 15px;
}

.group-theme__header--compact img {
  @include smallIcon;
  border-radius: 3px 0 0 3px;
}

.group-theme__logo{
  position: relative;
  top: 215px;
  width: 108px;
  height: 108px;
  background-size: contain;
  background-color: white;
  background-repeat: no-repeat;
  background-position-y: center;
  border: 4px solid #fff;
  &:hover .group-theme__upload-photo {
    button { background: $background-transparent-color; }
    .group-theme__upload-help-text { opacity: 1; }
  }
}

.group-theme__logo--compact {
  display: table-cell;
  img { background: white; }
}

.group-theme__name-and-actions{
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 175px;
}

@media (max-width: $small-max-px){
  .group-theme__name-and-actions{
    flex-direction: column;
    align-items: flex-start;
  }
}


.group-theme__actions {
  display: flex;
  margin-left: auto;
}

.group-theme__member-actions{
  display: flex;
}

.group-theme__name {
  margin-left: 108px + 15px;
  margin-right: 10px;
  a {
    color: $primary-text-color;
    &:hover { text-decoration: underline; }
  }
}

.group-theme__name--compact {
  display: table-cell;
  vertical-align: middle;
  background: rgba(0,0,0,.5);
  color: white;
  padding: 0 10px;
  border-radius: 0 3px 3px 0;
}

.group-theme__name--compact a {
  color: white;
}

.group-theme__upload-photo {
  cursor: pointer;
  width: 100%;
  button {
    transition: 0.25s background-color ease-in-out;
    border: 0;
    padding: 4px;
    border-radius: 4px;
    background: transparent;
  }
  i {
    margin-right: 4px;
    width: 24px;
  }
}

.group-theme__upload-photo i {
  color: white;
  text-shadow: 1px 1px 4px $grey-on-grey;
}

.group-theme__upload-help-text {
  transition: 0.25s opacity ease-in-out;
  opacity: 0;
  color: $primary-text-color;
}
</style>
