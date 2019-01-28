<style lang="scss">
.profile-page-card {
  @import 'lmo_card';
  position: relative;
  @include card;
}
</style>

<script lang="coffee">
AppConfig      = require 'shared/services/app_config'
Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'
LmoUrlService  = require 'shared/services/lmo_url_service'

{ submitForm }   = require 'shared/helpers/form'
{ hardReload }   = require 'shared/helpers/window'

module.exports =
  data: ->
    isDisabled: false
    user: null
  created: ->
    @init()
    EventBus.$emit 'currentComponent', { titleKey: 'profile_page.profile', page: 'profilePage'}
    EventBus.$on 'updateProfile', => @init()
  computed:
    showHelpTranslate: ->
      AppConfig.features.app.help_link
    availableLocales: ->
      AppConfig.locales
  methods:
    init: ->
      # return unless AbilityService.isLoggedIn()
      @user = Session.user().clone()
      Session.updateLocale(@user.locale)
      @submit = submitForm @, @user,
        flashSuccess: 'profile_page.messages.updated'
        submitFn: Records.users.updateProfile
        successCallback: @init

      changePicture: ->
        ModalService.open 'ChangePictureForm'

      changePassword: ->
        ModalService.open 'ChangePasswordForm'

      deactivateUser: ->
        ModalService.open 'ConfirmModal', confirm: ->
          text:
            title: 'deactivate_user_form.title'
            submit: 'deactivation_modal.submit'
            fragment: 'deactivate_user'
          submit: -> ModalService.open 'ConfirmModal', confirm: confirm

      deleteUser: ->
        ModalService.open 'ConfirmModal', confirm: ->
          text:
            title: 'delete_user_modal.title'
            submit: 'delete_user_modal.submit'
            fragment: 'delete_user_modal'
          submit: -> Records.users.destroy()
          successCallback: hardReload

      confirm: ->
        scope: {user: Session.user()}
        submit: -> Records.users.deactivate(Session.user())
        text:
          title:    'deactivate_user_form.title'
          submit:   'deactivate_user_form.submit'
          fragment: 'deactivate_user_confirmation'
        successCallback: hardReload

</script>
<template>
  <div class="loading-wrapper lmo-one-column-layout">
      <loading v-if="!user"></loading>
      <main v-if="user" class="profile-page">
          <div class="lmo-page-heading">
              <h1 v-t="'profile_page.profile'" class="lmo-h1-medium"></h1></div>
          <div class="profile-page-card">
              <div v-show="isDisabled" class="lmo-disabled-form"></div>
              <h3 v-t="'profile_page.edit_profile'" class="lmo-h3"></h3>
              <div class="profile-page__profile-fieldset">
                  <user-avatar :user="user" size="featured"></user-avatar>
                  <v-btn @click="changePicture()" v-t="'profile_page.change_picture_link'" class="md-accent md-button--no-h-margin profile-page__change-picture"></v-btn>
              </div>
              <div class="profile-page__profile-fieldset">
                  <div class="md-block">
                      <label for="user-name-field" translate="profile_page.name_label"></label>
                      <input required="ng-required" v-model="user.name" class="profile-page__name-input" id="user-name-field">
                      <validation-errors :subject="user" field="name"></validation-errors>
                  </div>
                  <div class="md-block">
                      <label for="user-username-field" translate="profile_page.username_label"></label>
                      <input required="ng-required" v-model="user.username" class="profile-page__username-input" id="user-username-field">
                      <div v-t="'profile_page.username_helptext'" class="md-caption"></div>
                      <validation-errors :subject="user" field="username"></validation-errors>
                  </div>
                  <div class="md-block">
                      <label for="user-email-field" translate="profile_page.email_label"></label>
                      <input required="ng-required" v-model="user.email" class="profile-page__email-input" id="user-email-field">
                      <validation-errors :subject="user" field="email"></validation-errors>
                  </div>
                  <div class="md-block">
                      <label for="user-short-bio-field" translate="profile_page.short_bio_label"></label>
                      <textarea v-model="user.shortBio" :placeholder="$t('profile_page.short_bio_placeholder')" class="profile-page__short-bio-input" id="user-short-bio-field"></textarea>
                      <validation-errors :subject="user" field="shortBio"></validation-errors>
                  </div>
                  <div class="md-block">
                      <label for="user-location-field" v-t="'profile_page.location_label'"></label>
                      <input v-model="user.location" :placeholder="$t('profile_page.location_placeholder')" class="profile-page__location-input" id="user-location-field">
                  </div>
                  <div class="md-block">
                      <label for="user-locale-field" translate="profile_page.locale_label"></label>
                      <!-- <md-select v-model="user.selectedLocale" required="true" class="profile-page__language-input" id="user-locale-field">
                          <md-option ng-repeat="locale in availableLocales" ng-value="locale.key">{{locale.name}}</md-option>
                      </md-select> -->
                      <validation-errors :subject="user" field="selectedLocale"></validation-errors>
                  </div>
                  <p v-if="showHelpTranslate">
                      <router-link v-t="'profile_page.help_translate'" to="https://www.loomio.org/g/cpaM3Hsv/loomio-community-translation" target="_blank" class="md-caption"></router-link>
                  </p>
              </div>
              <div class="profile-page__update-account lmo-flex lmo-flex__space-between">
                  <v-btn @click="changePassword()" v-t="'profile_page.change_password_link'" class="md-accent profile-page__change-password"></v-btn>
                  <v-btn @click="submit()" :disabled="isDisabled" v-t="'profile_page.update_profile'" class="md-primary md-raised profile-page__update-button"></v-btn>
              </div>
          </div>
          <div class="profile-page-card">
              <h3 v-t="'profile_page.deactivate_account'" class="lmo-h3"></h3>
              <v-btn @click="deactivateUser()" v-t="'profile_page.deactivate_user_link'" class="md-warn md-button--no-h-margin profile-page__deactivate"></v-btn>
              <h3 v-t="'profile_page.delete_account'" class="lmo-h3"></h3>
              <v-btn @click="deleteUser()" v-t="'profile_page.delete_user_link'" class="md-warn md-button--no-h-margin profile-page__delete"></v-btn>
          </div>
      </main>
  </div>
</template>
