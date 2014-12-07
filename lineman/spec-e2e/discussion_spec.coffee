describe 'Discussion Page', ->
  it 'adds a comment', ->
    browser.get('http://localhost:8000/angular_support/setup_for_add_comment')
    element(By.css('.cuke-nav-inbox-btn')).click()
    element.all(By.css('.cuke-inbox-item')).first().click()
    element(By.css('.cuke-comment-field')).sendKeys('hi this is my comment')
    element(By.css('.cuke-comment-submit')).click()
    expect(element.all(By.css('.thread-event-body')).last().getText()).toContain('hi this is my comment')

