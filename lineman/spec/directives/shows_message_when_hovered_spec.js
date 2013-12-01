describe("directive: shows-message-when-hovered (vanilla jasmine, coffeescript)", function() {

  beforeEach(function() {
    module("app");
  });

  beforeEach(inject(function($rootScope, $compile) {
    this.directiveMessage = 'ralph was here';
    this.html = "<div shows-message-when-hovered message='" + this.directiveMessage + "'></div>";
    this.scope = $rootScope.$new();
    this.scope.message = this.originalMessage = 'things are looking grim';
    this.elem = $compile(this.html)(this.scope);
  }));

  describe("when a user mouses over the element", function() {
    it("sets the message on the scope to the message attribute of the element", function() {
      this.elem.triggerHandler('mouseenter');
      expect(this.scope.message).toBe(this.directiveMessage);
    });
  });

  describe("when a users mouse leaves the element", function() {
    it("restores the message to the original", function() {
      this.elem.triggerHandler('mouseleave');
      expect(this.scope.message).toBe(this.originalMessage);
    });
  });

});
