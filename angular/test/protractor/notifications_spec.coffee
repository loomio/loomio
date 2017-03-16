describe 'Notifications', ->
  page = require './helpers/page_helper.coffee'

  it 'has all the notifications', ->
    page.loadPath 'setup_all_notifications', 60000

    page.expectText '.notifications__activity', '11'
    page.click '.notifications__button'

    page.expectText '.notifications__dropdown', 'accepted your invitation to join'
    page.expectText '.notifications__dropdown', 'added you to the group'
    page.expectText '.notifications__dropdown', 'approved your request'
    page.expectText '.notifications__dropdown', 'requested membership to'
    page.expectText '.notifications__dropdown', 'mentioned you in'
    page.expectText '.notifications__dropdown', 'replied to your comment'
    page.expectText '.notifications__dropdown', 'published an outcome'
    page.expectText '.notifications__dropdown', 'Proposal closed'
    page.expectText '.notifications__dropdown', 'Proposal is closing'
    page.expectText '.notifications__dropdown', 'liked your comment'
    page.expectText '.notifications__dropdown', 'made you a coordinator'

  describe 'invitation accepted', ->

    it 'notifies inviter when invitation is accepted', ->
      page.loadPath 'setup_group', 60000
      page.click '.members-card__invite-members-btn'
      page.fillIn '.invitation-form__email-addresses', 'max@example.com'
      page.click '.invitation-form__submit'
      page.loadPath 'accept_last_invitation', 60000
      page.click '.notifications__button'
      page.expectText '.notifications__dropdown', 'Max Von Sydow accepted your invitation to join Dirty Dancing Shoes'
