var protractor = require('protractor');
require('protractor/jasminewd');

describe('my angular app', function () {
  var ptor;

  describe('visiting the books page', function () {
    ptor = protractor.getInstance();

    beforeEach(function () {
      ptor.get('/list-of-books');
    });

    it('should show me a list of books', function() {
      ptor.findElement(
        protractor.By.repeater('book in books').row(0)).
        getText().then(function(text) {
          expect(text).toEqual('Great Expectations by Dickens');
        });

      ptor.findElement(
        protractor.By.repeater('book in books').row(1)).
        getText().then(function(text) {
          expect(text).toEqual('Foundation Series by Asimov');
        });

      ptor.findElement(
        protractor.By.repeater('book in books').row(2)).
        getText().then(function(text) {
          expect(text).toEqual('Treasure Island by Stephenson');
        });
    });
  });
});
