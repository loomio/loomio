describe 'Notifications', ->
  page = require './helpers/page_helper.coffee'

  it 'has all the notifications', ->
    page.loadPath 'setup_all_notifications', 120000

    notificationTexts = [
      'accepted your invitation to join',
      'added you to the group',
      'approved your request',
      'requested membership to',
      'mentioned you in',
      'replied to your comment',
      'shared an outcome',
      'Poll is closing soon',
      'started a Poll',
      'reacted to your comment',
      'made you a coordinator',
      'participated in',
      'added options to'
    ]

    page.expectText '.notifications__activity', notificationTexts.length

    page.click '.notifications__button'
    notificationTexts.map (text) ->
      page.expectText '.notifications__dropdown', text



  describe 'invitation accepted', ->

    it 'notifies inviter when invitation is accepted', ->
      page.loadPath 'setup_group', 60000
      page.click '.members-card__invite-members-btn'
      page.fillIn '.invitation-form__email-addresses', 'max@example.com'
      page.click '.invitation-form__submit'
      page.loadPath 'accept_last_invitation', 60000
      page.click '.notifications__button'
      page.expectText '.notifications__dropdown', 'Max Von Sydow accepted your invitation to join Dirty Dancing Shoes'
