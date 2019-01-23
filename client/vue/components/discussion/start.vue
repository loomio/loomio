<script lang="coffee">
</script>

<template>
  <v-card>
    <v-card-title class="headline">Use Google's location service?</v-card-title>
    <v-card-text>
      Let Google help apps determine location. This means sending anonymous location data to Google, even when no apps are running.
    </v-card-text>

    <v-card-actions>
      <v-spacer></v-spacer>

      <v-btn
      color="green darken-1"
      flat="flat"
      @click="dialog = false"
      >
      Disagree
    </v-btn>

    <v-btn
    color="green darken-1"
    flat="flat"
    @click="dialog = false"
    >
    Agree
  </v-btn>
</v-card-actions>
  </v-card>
</template>

<style lang="scss">
</style>
