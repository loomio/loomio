<script lang="coffee">
import { submitMembership } from '@/shared/helpers/form'
import MembershipModalMixin from '@/mixins/membership_modal'
import Flash   from '@/shared/services/flash'
import { onError } from '@/shared/helpers/form'

export default
  mixins: [MembershipModalMixin]
  props:
    membership: Object
    close: Function
  data: ->
    isDisabled: false
  methods:
    submit: ->
      @membership.save()
      .then =>
        Flash.success "membership_form.updated"
        @closeModal()
      .catch onError(@membership)

</script>
<template lang="pug">
v-card.membership-modal
  submit-overlay(:value='membership.processing')
  v-card-title
    h1.headline(v-t="'membership_form.modal_title.group'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text.membership-form
    p.lmo-hint-text.membership-form__helptext(v-t="{ path: 'membership_form.title_helptext.group', args: { name: membership.user().name } }")
    label(for='membership-title', v-t="'membership_form.title_label'")
    v-text-field#membership-title.membership-form__title-input.lmo-primary-form-input(:placeholder="$t('membership_form.title_placeholder')" v-model='membership.title', maxlength='255')
    validation-errors(:subject='membership', field='title')
  v-card-actions.membership-form-actions
    v-spacer
    v-btn.membership-form__submit(color="primary" @click='submit()' v-t="'common.action.save'")
</template>
