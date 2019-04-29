<style lang="scss">
.profile-page-card {
  @import 'lmo_card';
  position: relative;
  @include card;
}
</style>

<script lang="coffee">
import AppConfig      from '@/shared/services/app_config'
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import ConfirmModalMixin from '@/mixins/confirm_modal'
import ChangePasswordModalMixin from '@/mixins/change_password_modal'

import { submitForm }   from '@/shared/helpers/form'
import { hardReload }   from '@/shared/helpers/window'

export default
  mixins: [
    ConfirmModalMixin,
    ChangePasswordModalMixin
  ]
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
    deactivateUserConfirmOpts: ->
      text:
        title: 'deactivate_user_form.title'
        submit: 'deactivation_modal.submit'
        fragment: 'deactivate_user'
      submit: -> Promise.resolve console.log 'submit'
      successCallback: =>
        Promise.resolve @openConfirmModal(@reallyDeactivateUserConfirmOpts)
    deleteUserConfirmOpts: ->
      text:
        title: 'delete_user_modal.title'
        submit: 'delete_user_modal.submit'
        fragment: 'delete_user_modal'
      submit: -> Records.users.destroy()
      successCallback: hardReload

    reallyDeactivateUserConfirmOpts: ->
      scope: {user: Session.user()}
      submit: -> Records.users.deactivate(Session.user())
      text:
        title:    'deactivate_user_form.title'
        submit:   'deactivate_user_form.submit'
        fragment: 'deactivate_user_confirmation'
      successCallback: hardReload
  methods:
    init: ->
      # return unless Session.isSignedIn()
      @user = Session.user().clone()
      Session.updateLocale(@user.locale)
      @submit = submitForm @, @user,
        flashSuccess: 'profile_page.messages.updated'
        submitFn: Records.users.updateProfile
        successCallback: @init

    changePicture: ->
      ModalService.open 'ChangePictureForm'

    changePassword: ->
      @openChangePasswordModal(@user)

    openDeleteUserModal: ->
      @isDeleteUserModalOpen = true
    closeDeleteUserModal: ->
      @isDeleteUserModalOpen = false


</script>
<template lang="pug">
.loading-wrapper
  loading(v-if='!user')
  main.profile-page(v-if='user')
    h1.lmo-h1-medium(v-t="'profile_page.profile'")
    .profile-page-card
      //- .lmo-disabled-form(v-show='isDisabled')
      h3.lmo-h3(v-t="'profile_page.edit_profile'")
      .profile-page__profile-fieldset
        user-avatar(:user='user', size='featured')
        v-btn.md-accent.md-button--no-h-margin.profile-page__change-picture(@click='changePicture()', v-t="'profile_page.change_picture_link'")
      .profile-page__profile-fieldset
        .md-block
          label(for='user-name-field', translate='profile_page.name_label')
          input#user-name-field.profile-page__name-input(required='ng-required', v-model='user.name')
          validation-errors(:subject='user', field='name')
        .md-block
          label(for='user-username-field', translate='profile_page.username_label')
          input#user-username-field.profile-page__username-input(required='ng-required', v-model='user.username')
          .md-caption(v-t="'profile_page.username_helptext'")
          validation-errors(:subject='user', field='username')
        .md-block
          label(for='user-email-field', translate='profile_page.email_label')
          input#user-email-field.profile-page__email-input(required='ng-required', v-model='user.email')
          validation-errors(:subject='user', field='email')
        .md-block
          label(for='user-short-bio-field', translate='profile_page.short_bio_label')
          lmo-textarea(:model='user' field="shortBio" :placeholder="$t('profile_page.short_bio_placeholder')")
          validation-errors(:subject='user', field='shortBio')
        .md-block
          label(for='user-location-field', v-t="'profile_page.location_label'")
          input#user-location-field.profile-page__location-input(v-model='user.location', :placeholder="$t('profile_page.location_placeholder')")
        .md-block
          label(for='user-locale-field', translate='profile_page.locale_label')
            //- <md-select v-model="user.selectedLocale" required="true" class="profile-page__language-input" id="user-locale-field">
            //- <md-option ng-repeat="locale in availableLocales" ng-value="locale.key">{{locale.name}}</md-option>
            //- </md-select>
          validation-errors(:subject='user', field='selectedLocale')
        p(v-if='showHelpTranslate')
          router-link.md-caption(v-t="'profile_page.help_translate'", to='https://www.loomio.org/g/cpaM3Hsv/loomio-community-translation', target='_blank')
      .profile-page__update-account.lmo-flex.lmo-flex__space-between
        v-btn.md-accent.profile-page__change-password(@click='changePassword()', v-t="'profile_page.change_password_link'")
        v-btn.md-primary.md-raised.profile-page__update-button(@click='submit()', :disabled='isDisabled', v-t="'profile_page.update_profile'")
    .profile-page-card
      h3.lmo-h3(v-t="'profile_page.deactivate_account'")
      v-btn.md-warn.md-button--no-h-margin.profile-page__deactivate(@click='openConfirmModal(deactivateUserConfirmOpts)', v-t="'profile_page.deactivate_user_link'")

      h3.lmo-h3(v-t="'profile_page.delete_account'")
      v-btn.md-warn.md-button--no-h-margin.profile-page__delete(@click='openConfirmModal(deleteUserConfirmOpts)', v-t="'profile_page.delete_user_link'")

</template>
