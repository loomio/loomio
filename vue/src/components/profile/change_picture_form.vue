<script lang="coffee">
import Session  from '@/shared/services/session'
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'

import { submitForm, uploadForm } from '@/shared/helpers/form'
export default
  props:
    close: Function
  data: ->
    user: Session.user().clone()
  methods:
    selectFile: ->
      setTimeout -> document.querySelector('.change-picture-form__file-input').click()
  created: ->
    @submit = submitForm @, @user,
      flashSuccess: 'profile_page.messages.picture_changed'
      submitFn:     Records.users.updateProfile
      prepareFn:    (kind) => @user.avatarKind = kind
      cleanupFn:    -> EventBus.$emit 'closeModal'

    uploadForm @, $element, @user,
      flashSuccess:   'profile_page.messages.picture_changed'
      submitFn:       Records.users.uploadAvatar
      cleanupFn:      -> EventBus.$emit 'closeModal'
</script>
<template lang="pug">
v-card.change-picture-form
  v-card-title
    h1.headline(v-t="'change_picture_form.title'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text
    p.lmo-hint-text(v-html="$t('change_picture_form.helptext')")
    .change-picture-form__options-list
      .change-picture-form__option
        v-btn(@click="submit('initials')")
          .user-avatar
            .user-avatar__initials--small {{user.avatarInitials}}
          span(v-t="'change_picture_form.use_initials'")
      .change-picture-form__option
        v-btn(@click="submit('gravatar')" v-t="'change_picture_form.use_gravatar'")
          .user-avatar
            //- v-img.user-avatar__img(:src='user.emailHash', :alt='user.name')
      .change-picture-form__option
        v-btn.change-picture-form__upload-button(@click='selectFile()' v-t="'change_picture_form.use_uploaded'")
          v-icon mdi-camera
        input.hidden.change-picture-form__file-input(file-select='upload')
</template>


<!--

  angular.module('loomioApp').factory 'ChangePictureForm', ['$rootScope', '$timeout', ($rootScope, $timeout) ->
    templateUrl: 'generated/components/change_picture_form/change_picture_form.html'
    controller: ['$scope', '$element', ($scope, $element) ->

      $scope.selectFile = ->
        $timeout -> document.querySelector('.change-picture-form__file-input').click()

      $scope.submit = submitForm $scope, $scope.user,
        flashSuccess: 'profile_page.messages.picture_changed'
        submitFn:     Records.users.updateProfile
        prepareFn:    (kind) -> $scope.user.avatarKind = kind
        cleanupFn:    -> EventBus.broadcast $rootScope, 'updateProfile'

      uploadForm $scope, $element, $scope.user,
        flashSuccess:   'profile_page.messages.picture_changed'
        submitFn:       Records.users.uploadAvatar
        cleanupFn:      -> EventBus.broadcast $rootScope, 'updateProfile'
    ]
  ] -->
