<script lang="coffee">
export default
  props:
    query: String
    filteredUsers: Array
    positionStyles: Object
    navigatedUserIndex: Number
    showUsername:
      type: Boolean
      default: false
</script>

<template lang="pug">
v-card.suggestion-list(outlined :elevation=8 v-show='query' ref='suggestions' :style="positionStyles")
  template(v-if='filteredUsers.length')
    v-list(dense)
      v-list-item(v-for='(user, index) in filteredUsers', :key='user.id', :class="{ 'v-list-item--active': navigatedUserIndex === index }", @click='selectUser(user)')
        v-list-item-title
          | {{ user.name }}
          span.grey--text(v-if="showUsername") &nbsp; {{ "@" + user.username }}
  v-card-subtitle(v-else v-t="'common.no_results_found'")
</template>
