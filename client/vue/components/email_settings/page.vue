<style lang="scss">
.email-settings-page {
  @import 'layout';
  @include lmoRow;
}

.email-settings-page__email-settings {
  @import 'lmo_card';
  @include card;
}

.email-settings-page__specific-group-settings {
  margin-top: 40px;
}

.email-settings-page__group {
  padding: 12px 0 !important;
}

.email-settings-page__learn-more-link {
  @import 'lmo_card';
  @include cardMinorAction;
}
</style>

<script lang="coffee">
Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
AppConfig      = require 'shared/services/app_config'
ModalService   = require 'shared/services/modal_service'
LmoUrlService  = require 'shared/services/lmo_url_service'

{ submitForm }   = require 'shared/helpers/form'

module.exports =
  data: ->
    newsletterEnabled: AppConfig.newsletterEnabled
    user: null
  created: ->
    @init()
  methods:
    init: ->
      return unless AbilityService.isLoggedIn() or Session.user().restricted?
      @user = Session.user().clone()
      @submit = submitForm @, @user,
        submitFn: Records.users.updateProfile
        flashSuccess: 'email_settings_page.messages.updated'
        successCallback: -> LmoUrlService.goTo '/dashboard' if AbilityService.isLoggedIn()

    groupVolume: (group) ->
      group.membershipFor(Session.user()).volume

    changeDefaultMembershipVolume: ->
      ModalService.open 'ChangeVolumeForm', model: => Session.user()

    editSpecificGroupVolume: (group) ->
      ModalService.open 'ChangeVolumeForm', model: => group.membershipFor(Session.user())
  computed:
    defaultSettingsDescription: ->
      "email_settings_page.default_settings.#{Session.user().defaultMembershipVolume}_description"
</script>

<template>
  <div class="lmo-one-column-layout">
    <main v-if="user" class="email-settings-page">
      <div class="lmo-page-heading">
        <h1 v-t="'email_settings_page.header'" class="lmo-h1-medium"></h1>
      </div>
      <div class="email-settings-page__email-settings">
        <div class="email-settings-page__global-settings">
          <form @submit="submit()">
            <div class="email-settings-page__global-settings">
              <v-checkbox v-model="user.emailCatchUp" class="md-checkbox--with-summary email-settings-page__daily-summary" id="daily-summary-email">
                <strong for="daily-summary-email" v-t="email_settings_page.daily_summary_label"></strong>
                <div v-t="'email_settings_page.daily_summary_description'" class="email-settings-page__input-description"></div>
              </v-checkbox>
              <v-checkbox v-model="user.emailOnParticipation" class="md-checkbox--with-summary email-settings-page__on-participation" id="on-participation-email">
                <strong for="on-participation-email" v-t="'email_settings_page.on_participation_label'"></strong>
                <div v-t="'email_settings_page.on_participation_description'" class="email-settings-page__input-description"></div>
              </v-checkbox>
              <v-checkbox v-model="user.emailWhenMentioned" class="md-checkbox--with-summary email-settings-page__mentioned" id="mentioned-email">
                <strong for="mentioned-email" v-t="'email_settings_page.mentioned_label'"></strong>
                <div v-t="'email_settings_page.mentioned_description'" class="email-settings-page__input-description"></div>
              </v-checkbox>
              <v-checkbox v-model="user.emailNewsletter" v-if="newsletterEnabled" class="md-checkbox--with-summary email-settings-page__promotions" id="email-promotions">
                <strong for="email-newsletter" v-t="'email_settings_page.email_newsletter'"></strong>
                <div v-t="'email_settings_page.email_newsletter_description'" class="email-settings-page__input-description"></div>
              </v-checkbox>
            </div>
            <v-btn type="submit" ng-disabled="isDisabled" v-t="'email_settings_page.update_settings'" class="md-primary md-raised email-settings-page__update-button"></v-btn>
          </form>ß
        </div>
        <div class="email-settings-page__specific-group-settings">
            <h3 v-t="'email_settings_page.specific_groups'" class="lmo-h3"></h3>
            <v-list class="email-settings-page__großups">
              <v-list-tile class="email-settings-page__group lmo-flex lmo-flex__space-between">
                <div class="lmo-box--medium lmo-margin-right lmo-flex lmo-flex__center lmo-flex__horizontal-center">
                  <i class="mdi mdi-account-multiple-plus mdi-24px"></i>
                </div>
                <div v-t="defaultSettingsDescription" class="email-settings-page__default-description"></div>
                <v-btn @click="changeDefaultMembershipVolume()" v-t="'common.action.edit'" class="md-accent email-settings-page__change-default-link"></v-btn>
              </v-list-tile>
              <v-list-tile v-for="group in user.formalGroups()" key="group.id" class="email-settings-page__group lmo-flex lmo-flex__space-between">
                <group-avatar :group="group" size="medium" class="lmo-margin-right"></group-avatar>
                <div class="email-settings-page__group-details lmo-flex__grow">
                  <strong class="email-settings-page__group-name">
                    <span v-if="group.isSubgroup()">{{group.parentName()}} -</span> <span>{{group.name}}</span>
                  </strong>
                  <div v-t="'change_volume_form.{{groupVolume(group)}}_label'" class="email-settings-page__membership-volume"></div>
                </div>
                <div class="email-settings-page__edit">
                  <v-btn @click="editSpecificGroupVolume(group)" v-t="'email_settings_page.edit'" class="md-accent email-settings-page__edit-membership-volume-link"></v-btn>
                </div>
              </v-list-tile>
            </v-list>
            <a href="https://help.loomio.org/en/user_manual/users/email_settings/" target="_blank" v-t="'email_settings_page.learn_more'" class="email-settings-page__learn-more-link"></a>
        </div>
      </div>
    </main>
  </div>
</template>
