<script lang="coffee">
export default
  props:
    error: Object
</script>
<template lang="pug">
v-container
  .error-page.text-center
    .error-page__forbidden(v-t="'error_page.forbidden'" v-if="error.status == 403")
    .error-page__page-not-found(v-t="'error_page.page_not_found'" v-if="error.status == 404")
    .error-page__internal-server-error(v-t="'error_page.internal_server_error'" v-if="error.status == 500")
</template>
