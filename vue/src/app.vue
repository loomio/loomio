<template lang="pug">
  v-app
    navbar
    sidebar
    v-content
      router-view(:key="$route.path")
    modal-launcher
</template>
