#describe 'angular homepage', ->
  #firstNumber = element(By.model('first'))
  #secondNumber = element(By.model('second'))
  #goButton = element(By.id('gobutton'))
  #latestResult = element(By.binding('latest'))
  #history = element.all(By.repeater('result in memory'))

  #add = (a, b) ->
    #firstNumber.sendKeys(a)
    #secondNumber.sendKeys(b)
    #goButton.click()

  #beforeEach ->
    #browser.get('http://juliemr.github.io/protractor-demo/')

  #it 'should have a title', ->
    #expect(browser.getTitle()).toEqual('Super Calculator')

  #it 'should add 1 and 2', ->
    #firstNumber.sendKeys(1)
    #secondNumber.sendKeys(2)

    #goButton.click()

    #expect(latestResult.getText()).toEqual('3');

  #it 'should add 4 and 6', ->
    #firstNumber.sendKeys(4)
    #secondNumber.sendKeys(6)

    #goButton.click()

    #expect(latestResult.getText()).toEqual('10');

  #it 'should have a history', ->
    #add(1, 2)
    #add(3, 4)

    #expect(history.count()).toEqual(2)

    #add(5,6)
    #expect(history.count()).toEqual(3)

    #expect(history.last().getText()).toContain('1 + 2')
    #expect(history.first().getText()).toContain('5 + 6')
 
