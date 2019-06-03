<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'

export default
  mixins: [ WatchRecords ]
  props:
    discussion: Object

  data: ->
    canAddComment: false

  mounted: ->
    @watchRecords
      key: @discussion.id
      collections: ['groups', 'memberships']
      query: (store) =>
        @canAddComment = AbilityService.canAddComment(@discussion)
</script>

<template lang="pug">
.add-comment-panel.lmo-card-padding
  comment-form(:discussion='discussion')
  .add-comment-panel__join-actions(v-if='!canAddComment')
    join-group-button(:group='discussion.group()', v-if='isLoggedIn()', :block='true')
    v-btn.md-primary.md-raised.add-comment-panel__sign-in-btn(v-t="'comment_form.sign_in'", @click='signIn()', v-if='!isLoggedIn()')
</template>
