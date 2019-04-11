<script lang="coffee">
export default
  props:
    user: Object
    close: Function
  # created: ->
  #   EventBus.listen $scope, '$close', $scope.$close
</script>
<template lang="pug">
v-card.contact-user-modal
  v-card-title
    h1.lmo-h1(v-t="{ path: 'contact_request_form.modal_title', args: { name: user.name }}")
    dismiss-modal-button(:close="close")
  v-card-text
    contact-request-form(:user="user")
</template>
