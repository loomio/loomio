<script lang="js">
export default {
  props: ['error']
}
</script>
<template>

<v-main class="pb-12">
  <v-container>
    <div class="error-page text-center">
      <div class="error-page__forbidden" v-t="'error_page.forbidden_view'" v-if="error.status == 403"></div>
      <div class="error-page__page-not-found" v-t="'error_page.page_not_found'" v-if="error.status == 404"></div>
      <div class="error-page__internal-server-error" v-t="'error_page.internal_server_error'" v-if="error.status == 500"></div>
    </div>
  </v-container>
</v-main>
</template>
