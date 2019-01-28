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

<template lang="pug">
.group-theme
  .group-theme__cover.lmo-no-print
    .group-theme__upload-photo(v-if='canUploadPhotos')
      button.lmo-flex.lmo-flex__center(@click='openUploadCoverForm()', :title="$t('group_page.new_cover_photo')")
        i.mdi.mdi-camera.mdi-24px
        span.group-theme__upload-help-text.caption(translate='group_page.new_photo')
  .group-theme__header--compact(v-if='compact')
    .group-theme__logo--compact(aria-hidden='true')
      router-link(:to='urlFor(group)')
        img(:src='group.logoUrl()', :alt="$t('group_page.group_logo')")
    .group-theme__name--compact(aria-label='breadcrumb', role='navigation')
      router-link(v-if='group.isSubgroup()', :to='urlFor(group.parent())') {{group.parentName()}}
      span(v-if='group.isSubgroup()') -
      router-link(:to='urlFor(group)', aria-current='page') {{group.name}}
      span(v-if='discussion') -
      router-link(v-if='discussion', :to='urlFor(discussion)', aria-current='page') {{discussion.title}}
  .group-theme__header(v-if='!compact')
    .group-theme__logo(:style='logoStyle', :alt="$t('group_page.group_logo')")
      .group-theme__upload-photo(v-if='canUploadPhotos')
        button.lmo-flex.lmo-flex__center(@click='openUploadLogoForm()', :title="$t('group_page.new_group_logo')")
          i.mdi.mdi-camera.mdi-24px
          span.group-theme__upload-help-text(v-t="'group_page.new_photo'")
    .group-theme__name-and-actions
      h1.lmo-h1.group-theme__name(aria-label='breadcrumb', role='navigation')
        router-link(v-if='group.isSubgroup()', :to='urlFor(group.parent())') {{group.parentName()}}
        span(v-if='group.isSubgroup()') -
        router-link(:to='urlFor(group)') {{group.name}}
      .group-theme__actions(v-if='homePage')
        join-group-button(:group='group')
        // <outlet name="group-theme-actions" model="group"></outlet>
        .group-theme__member-actions(v-if='canPerformActions')
          // <outlet name="group-theme-member-actions" model="group"></outlet>
          group-privacy-button(:group='group')
          group-actions-dropdown(:group='group')
</template>

<style lang="scss">
@import 'app.scss';
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
  // margin-left: 108px + 15px;
  // margin-right: 10px;
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
