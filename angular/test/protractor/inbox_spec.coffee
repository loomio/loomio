describe 'Inbox Page', ->

  page = require './helpers/page_helper.coffee'

  it 'displays unread threads by group', ->
    page.loadPath 'setup_inbox'

    page.expectText '.inbox-page', 'Dirty Dancing Shoes'
    page.expectText '.inbox-page', 'Pinned discussion'
    page.expectElement '.thread-preview__pin'

    page.expectText '.inbox-page', 'Point Break'
    page.expectText '.inbox-page', 'Recent discussion'

    page.expectNoText '.inbox-page', 'Muted discussion'
    page.expectNoText '.inbox-page', 'Old discussion'
