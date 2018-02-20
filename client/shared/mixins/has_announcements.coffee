module.exports = new class HasDocuments
  apply: (model, opts = {}) ->
    model.announcements = ->
      model.recordStore.announcements.find model.announcementIds

    model.announcementRecipients = ->
      model.announcementUsers().concat model.announcementInvitations()

    model.announcementUsers = ->
      model.recordStore.users.find _.flatten _.pluck @announcements(), 'userIds'

    model.announcementInvitations = ->
      model.recordStore.invitations.find _.flatten _.pluck @announcements(), 'invitationIds'

    model.announcedAtFor = (thing) ->
      relation = switch thing.constructor.singular
        when 'invitation' then 'invitationIds'
        when 'user'       then 'userIds'
      _.find(model.announcements(), (announcement) ->
        _.contains announcement[relation], thing.id
      ).createdAt

    model.announcementsApplied = true
