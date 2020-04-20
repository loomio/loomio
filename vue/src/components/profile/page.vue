<script lang="coffee">
import AppConfig      from '@/shared/services/app_config'
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import openModal      from '@/shared/helpers/open_modal'
import UserService    from '@/shared/services/user_service'
import Flash   from '@/shared/services/flash'
import { onError } from '@/shared/helpers/form'
import { includes, uniq, debounce } from 'lodash'

export default
  data: ->
    user: null
    originalUser: null
    existingEmails: []

  created: ->
    @init()
    EventBus.$emit 'currentComponent', { titleKey: 'profile_page.edit_profile', page: 'profilePage'}
    EventBus.$on 'updateProfile', => @init()
    EventBus.$on 'signedIn', => @init()

  computed:
    showHelpTranslate: -> AppConfig.features.app.help_link
    availableLocales: -> AppConfig.locales
    actions: -> UserService.actions(Session.user(), @)
    emailExists: -> includes(@existingEmails, @user.email)

  methods:
    init: ->
      return unless Session.isSignedIn()
      @originalUser = Session.user()
      @user = @originalUser.clone()
      Session.updateLocale(@user.locale)

    changePicture: ->
      openModal
        component: 'ChangePictureForm'

    changePassword: ->
      @openChangePasswordModal(@user)

    openDeleteUserModal: ->
      @isDeleteUserModalOpen = true

    closeDeleteUserModal: ->
      @isDeleteUserModalOpen = false

    openSendVerificationModal: ->
      openModal
        component: 'ConfirmModal'
        props:
          confirm:
            submit: => Records.users.sendMergeVerificationEmail(@user.email)
            text:
              title:    'merge_accounts.modal.title'
              raw_helptext: @$t('merge_accounts.modal.helptext', sourceEmail: @originalUser.email, targetEmail: @user.email)
              submit:   'merge_accounts.modal.submit'
              flash:    'merge_accounts.modal.flash'

    checkEmailExistence: debounce ->
      return if @originalUser.email == @user.email
      Records.users.checkEmailExistence(@user.email).then (res) =>
        if res.exists
          @existingEmails = uniq(@existingEmails.concat([res.email]))
    , 250

    submit: ->
      Records.users.updateProfile(@user)
      .then =>
        Flash.success 'profile_page.messages.updated'
        @init()
      .catch onError(@user)

</script>
<template lang="pug">
v-content
  v-container.profile-page.max-width-1024
    loading(v-if='!user')
    div(v-if='user')
      v-card
        submit-overlay(:value='user.processing')
        //- v-card-title
        //-   h1.headline(v-t="'profile_page.edit_profile'")
        v-card-text
          v-layout
            v-flex.profile-page__details
              v-layout(:column="$vuetify.breakpoint.xs")
                v-flex
                  v-text-field.profile-page__name-input(:label="$t('profile_page.name_label')" required v-model="user.name")
                  validation-errors(:subject='user', field='name')

                  v-text-field#user-username-field.profile-page__username-input(:label="$t('profile_page.username_label')" required v-model="user.username")
                  validation-errors(:subject='user', field='username')

                  //- span existingEmails: {{ existingEmails }}
                  v-text-field#user-email-field.profile-page__email-input(:label="$t('profile_page.email_label')" required v-model='user.email' @keyup="checkEmailExistence")
                  validation-errors(:subject='user', field='email')
                  .profile-page__email-taken(v-if="emailExists")
                    span.email-taken-message(v-t="'merge_accounts.email_taken'")
                    space
                    a.email-taken-find-out-more(@click="openSendVerificationModal" v-t="'merge_accounts.find_out_more'")

                .profile-page__avatar.d-flex.flex-column.justify-center.align-center.mx-12(@click="changePicture()")
                  user-avatar.mb-4(:user='originalUser' size='featured' :no-link="true")
                  v-btn(color="accent" @click="changePicture" v-t="'profile_page.change_picture_link'")

              lmo-textarea(:model='user' field="shortBio" :label="$t('profile_page.short_bio_label')" :placeholder="$t('profile_page.short_bio_placeholder')")
              validation-errors(:subject='user', field='shortBio')

              v-text-field#user-location-field.profile-page__location-input(v-model='user.location' :label="$t('profile_page.location_label')" :placeholder="$t('profile_page.location_placeholder')")

              v-select#user-locale-field(:label="$t('profile_page.locale_label')" :items="availableLocales" v-model="user.selectedLocale" item-text="name" item-value="key")
              validation-errors(:subject='user', field='selectedLocale')
              p(v-if='showHelpTranslate')
                a(v-t="'profile_page.help_translate'" href='https://www.loomio.org/g/cpaM3Hsv/loomio-community-translation' target='_blank')
        v-card-actions.profile-page__update-account
          v-spacer
          v-btn.profile-page__update-button(color="primary" @click='submit()' :disabled='emailExists' v-t="'profile_page.update_profile'")

      v-card.profile-page-card.mt-4
        v-list
          v-list-item(v-for="(action, key) in actions" :key="key" v-if="action.canPerform()" @click="action.perform()" :class="'user-page__' + key")
            v-list-item-icon
              v-icon {{action.icon}}
            v-list-item-title(v-t="action.name")
        //-
        //-   v-btn.profile-page__change-password(color="accent" outlined @click='changePassword()' v-t="'profile_page.change_password_link'")
        //- v-card-text
        //-   h3.lmo-h3(v-t="'profile_page.deactivate_account'")
        //-   v-btn.profile-page__deactivate(outlined color="warning" @click='openConfirmModal(deactivateUserConfirmOpts)', v-t="'profile_page.deactivate_account'")
        //-
        //-   h3.lmo-h3(v-t="'profile_page.delete_account'")
        //-   v-btn.profile-page__delete(outlined color="warning" @click='openConfirmModal(deleteUserConfirmOpts)', v-t="'profile_page.delete_user_link'")

</template>
<style lang="sass">
.profile-page__avatar
  cursor: pointer
.email-taken-message
  color: red
</style>
