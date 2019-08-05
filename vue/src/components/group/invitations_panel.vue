<script lang="coffee">
import Records        from '@/shared/services/records'
import RecordLoader   from '@/shared/services/record_loader'
import { exact, approximate } from '@/shared/helpers/format_time'
import {orderBy, slice} from 'lodash'
export default
  data: ->
    loader: null
    group: Records.groups.fuzzyFind(@$route.params.key)
    search: @$route.query.q || ''
    subgroups: @$route.query.subgroups || 'none'
    per: 50
    from: 0
    order: 'accepted_at desc'

  created: ->
    @loader = new RecordLoader
      collection: 'memberships'
      path: 'autocomplete'
      params:
        q: @search
        group_id: @group.id
        subgroups: @subgroups
        pending: true
        per: @per
        from: @from
        order: @order

    @loader.fetchRecords()

    @watchRecords
      collections: ['memberships']
      query: @query

  methods:
    exact: exact
    approximate: approximate
    refresh: ->
      @fetch()
      @query()

    query: ->
      chain = Records.memberships.collection.chain()
      switch @subgroups
        when 'mine'
          chain = chain.find(groupId: {$in: intersection(@group.organisationIds(), Session.user().groupIds())})
        when 'all'
          chain = chain.find(groupId: {$in: @group.organisationIds()})
        else
          chain = chain.find(groupId: @group.id)

      if @search
        chain = chain.where (membership) =>
          some [membership.user().name, membership.user().username], (name) =>
            RegExp("^#{@search}", "i").test(name) or RegExp(" #{@search}", "i").test(name)


      records = switch @order
        when 'users.name'
          chain = chain.sort (ma,mb) ->
            a = ma.user().name.toLowerCase()
            b = mb.user().name.toLowerCase()
            switch
              when a == b then 0
              when a > b then 1
              when a < b then -1
          chain.data()
        when 'admin desc'
          chain.simplesort('admin', true).data()
        when 'created_at'
          chain.simplesort('createdAt').data()
        when 'created_at desc'
          chain.simplesort('createdAt', true).data()
        when 'accepted_at desc'
          orderBy chain.data(), [(m) -> m.acceptedAt || ''], ['asc']

      @memberships = slice(records, @loader.numRquested)

    fetch: ->
      @loader.fetchRecords
        q: @search
        from: @from
        order: @order
        subgroups: @subgroups

  watch:
    '$route.query.subgroups': (val) ->
      if ['mine', 'all'].includes(val)
        @subgroups = val
      else
        @subgroups = 'none'

    '$route.query.q': (val) ->
      @search = val
      @refresh()
</script>
<template lang="pug">
.invitations-panel
  v-simple-table
    thead
      tr
        th Photo
        th Name
        th Email
        th Accepted
        td(v-if="subgroups != 'none'") Subgroup
        th Invited by
        th Sent
    tbody
      tr(v-for="(membership, index) in memberships")
        td
          user-avatar.mr-4(:user='membership.user()', size='forty')
        td.members-panel__name
          v-layout(align-center)
            router-link(:to="urlFor(membership.user())") {{membership.user().name}}
        td.members-panel__email {{membership.user().email}}
        td.members-panel__accepted {{membership.acceptedAt ? approximate(membership.acceptedAt) : '' }}
        td(v-if="subgroups != 'none'") {{membership.group().name}}
        td {{membership.inviter() && membership.inviter().name}}
        td
          timeAgo(:date="membership.createdAt")
</template>
