<script lang="coffee">
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete'
import RecipientsAutocompleteMixin from '@/mixins/recipients_autocomplete_mixin'
import Session        from '@/shared/services/session'
import {map, filter, find} from 'lodash'

export default
  components:
    RecipientsAutocomplete: RecipientsAutocomplete

  mixins: [RecipientsAutocompleteMixin]

  data: ->
    initialRecipients: []
    reset: false

  props:
    model: Object

  methods:
    newRecipients: (val) ->
      @recipients = val
      @model.recipientAudience = (find(val, (o) -> o.type == 'audience') || {}).id
      @model.recipientUserIds = map filter(val, (o) -> o.type == 'user'), 'id'
      @model.recipientEmails = map filter(val, (o) -> o.type == 'email'), 'name'

  computed:
    modelName: -> @model.constructor.singular

    audiences: ->
      ret = []
      canAnnounce = !!(@model.group().adminsInclude(Session.user()) || @model.group().membersCanAnnounce)
      if @recipients.length == 0
        if @model.groupId && canAnnounce
          ret.push
            id: 'group'
            name: @model.group().name
            size: @model.group().acceptedMembershipsCount
            icon: 'mdi-account-group'
        if @model.discussion().id && @model.discussion().membersCount > 1
          ret.push
            id: 'discussion_group'
            name: @$t('announcement.audiences.discussion_group')
            size: @model.discussion().membersCount
            icon: 'mdi-forum'

        # voters
        # non voters
        # partiicpants
        # undecided

      ret.filter (a) =>
        (@query && a.name.match(new RegExp(@query, 'i'))) || true
</script>

<template lang="pug">
.common-notify-fields
  v-divider.my-6
  v-text-field(
    v-if="model.id"
    :label="$t('discussion_form.change_log_label')"
    :placeholder="$t('discussion_form.change_log_placeholder')"
    v-model="model.recipientMessage"
    counter="140")

  recipients-autocomplete(
    v-if="model.id"
    :label="$t(model.id ? 'action_dock.notify' : 'common.action.invite')"
    :placeholder="$t('announcement.form.'+modelName+'_'+ (model.id ? 'edited' : 'announced')+ '.helptext')"
    :users="users"
    :initial-recipients="initialRecipients"
    :audiences="audiences"
    :reset="reset"
    @new-query="newQuery"
    @new-recipients="newRecipients")
</template>
