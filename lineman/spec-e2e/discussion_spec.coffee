describe 'Discussion Page', ->

  page = null

  class DiscussionPage
    load: ->
      browser.get('http://localhost:8000/angular_support/setup_for_add_comment')
      element(By.css('.cuke-nav-inbox-btn')).click()
      element.all(By.css('.cuke-inbox-item')).first().click()

    addComment: (body) ->
      element(By.css('.cuke-comment-field')).sendKeys('hi this is my comment')
      element(By.css('.cuke-comment-submit')).click()

    mostRecentComment: ->
      element.all(By.css('.thread-comment')).last()

  beforeEach ->
    page = new DiscussionPage
    page.load()


  it 'adding a comment', ->
    page.addComment('hi this is my comment')
    expect(page.mostRecentComment().getText()).toContain('hi this is my comment')

  it 'replying to a comment', ->
    page.addComment('original comment right heerrr')
    page.mostRecentComment().element(By.css('.cuke-comment-reply-btn')).click()
    page.addComment('hi this is my comment')
    expect(page.mostRecentComment().element(By.css('.cuke-in-reply-to')).getText()).toContain('in reply to')

  it 'likeing a comment', ->
    page.addComment('hi')
    page.mostRecentComment().element(By.css('.cuke-comment-like-btn')).click()
    expect(element(By.css('.thread-liked-by-sentence')).getText()).toContain('You like this.')

  it 'starts a proposal', ->
    element(By.css('.thread-start-proposal-card')).element(By.tagName('a')).click()
    element(By.model('proposal.name')).sendKeys('I am an anaconda')
    element(By.model('proposal.description')).sendKeys('and I eat anaconda food')
    element(By.css('i.fa-calendar')).click()
    element(By.css('th.right')).click()
    element(By.css('th.right')).click()
    element.all(By.repeater('dateObject in week.dates')).first().click()
    element.all(By.css('span.hour')).last().click()
    element(By.css('.cuke-start-proposal-btn')).click()
    browser.debugger()
    expect(element(By.css('.proposal-expanded h2')).getText()).toContain('I am an anaconda')
    # expect proposal to be started


