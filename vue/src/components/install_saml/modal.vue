<script lang="coffee">
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import { submitForm } from '@/shared/helpers/form'
import { hardReload } from '@/shared/helpers/window'

export default
  props:
    close: Function
    group: Object
  data: ->
    groupIdentity: Records.groupIdentities.build
      groupId: @group.id
      identityType: 'saml'
    samlUrl: ''
  methods:
    hasIdentity: -> Session.user().identityFor('saml')

    redirect: ->
      @$router.push({ query: { install_saml: true } })
      hardReload('/saml/oauth?saml_url=' + @samlUrl)

  created: ->
    @submit = submitForm @, @groupIdentity,
      flashSuccess: 'install_saml.saml_connected'
      successCallback: => @close()
</script>
<template lang="pug">
v-card.install-saml-modal
  v-card-title
    h1.headline(v-t="'install_saml.modal_title'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text
    template(v-if="group.features.saml")
      template(v-if="hasIdentity()")
        p.lmo-hint-text(v-html="$t('install_saml.connect_helptext')")
      template(v-else)
        p.lmo-hint-text(v-t="'install_saml.auth_helptext'")
        v-text-field#saml-url.discussion-form__title-input(v-model='samlUrl' :placeholder="$t('install_saml.url_placeholder')")
          div(slot="label")
            span(v-html="$t('install_saml.url_label')")
    template(v-else)
      p.lmo-hint-text.install-saml-modal__contact(v-t="'install_saml.get_in_touch'")
  v-card-actions(v-if="group.features.saml")
    v-spacer
    v-btn.install-saml-modal__connect(v-if="hasIdentity()" color='primary' @click='submit()', v-t="'install_saml.connect_with_saml'")
    v-btn.install-saml-modal__login(v-else color='primary' @click='redirect()' v-t="'install_saml.login_with_saml'")
</template>
