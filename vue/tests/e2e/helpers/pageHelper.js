let base_url;
if (process.env.RAILS_ENV === 'test') {
  base_url = "http://localhost:3000";
} else {
  base_url = "http://localhost:8080";
}

module.exports = function(test, browser) {
  return {
    refresh() {
      return test.refresh();
    },

    loadPath(path, opts = {}) {
      test.url(`${base_url}/dev/${path}`);
      return test.waitForElementPresent('.app-is-booted', 10000);
    },

    loadPathNoApp(path, opts = {}) {
      return test.url(`${base_url}/dev/${path}`);
    },

    loadLastEmail() {
      return test.url(`${base_url}/dev/last_email`);
    },

    goTo(path) {
      return test.url(`${base_url}/${path}`);
    },

    waitForUrlToContain(string) {
      return test.assert.urlContains(string);
    },

    expectCount(selector, count, wait) {
      this.waitFor(selector, wait);
      return test.elements('css selector', selector, result => {
        return test.verify.equal(result.value.length, count);
      });
    },

    expectElement(selector, wait) {
      this.waitFor(selector, wait);
      return test.expect.element(selector).to.be.present;
    },

    expectNoElement(selector, wait = 1000) {
      return test.expect.element(selector).to.not.be.present.after(wait);
    },

    click(selector, pause) {
      this.waitFor(selector);
      test.moveToElement(selector, 10, 10)
      test.click(selector);
      if (pause) { return test.pause(pause); }
    },

    scrollTo(selector, callback, wait) {
      this.waitFor(selector, wait);
      return test.getLocationInView(selector, callback);
    },

    ensureSidebar() {
      this.waitFor('.navbar__sidenav-toggle');
      return test.click('.navbar__sidenav-toggle');
    },
      // test.elements 'css selector', '.sidenav-left', (result) =>
      //   if result.value.length == 0
      //     test.click('.navbar__sidenav-toggle')
      //     @waitFor('.sidenav-left')
      //   else
      //     console.log 'not there'

    ensureThreadNav() {
      return test.isVisible('.thread-nav__add-people' , function(result) {
        if (!result.value) {
          return test.click('.thread-page__open-thread-nav');
        }
      });
    },

    pause(time = 1000) {
      return test.pause(time);
    },

    debug() { return test.pause(9999999); },


    mouseOver(selector, callback, wait) {
      this.waitFor(selector, wait);
      return test.moveToElement(selector, 10, 10, callback);
    },

    clearField(selector) {
      return test.getValue(selector, function(result) {
        if (!(result || {}).value) { return; }
        const {
          length
        } = result.value;
        let count = 0;
        while (count < length) {
          test.keys([test.Keys.BACK_SPACE]);
          count += 1;
        }
        return test.pause(2000);
      });
    },

    fillIn(selector, value, wait) {
      this.pause(200);
      this.waitFor(selector, wait);
      // test.clearValue(selector)
      return test.setValue(selector, value);
    },

    fillInAndEnter(selector, value, wait) {
      this.pause(100);
      this.waitFor(selector, wait);
      // test.clearValue(selector)
      return test.setValue(selector, [value, test.Keys.ENTER]);
    },

    escape() {
      return test.keys(test.Keys.ESCAPE);
    },


    clear(selector, wait) {
      this.waitFor(selector, wait);
      return test.getValue(selector, function(result) {
        const chars = result.value.split('');
        chars.forEach(() => this.setValue(selector, test.Keys.RIGHT_ARROW));
        return chars.forEach(() => this.setValue(selector, test.Keys.BACK_SPACE));
        });
    },

    execute(script) {
      return test.execute(script);
    },

    selectFromAutocomplete(selector, value) {
      this.fillIn(selector, value);
      this.click(selector);
      this.pause();
      return this.execute("document.querySelector('.md-autocomplete-suggestions li').click()");
    },

    // selectOption: (selector, option) ->
    //   @waitFor(selector, 3000)
    //   test.setValue(selector, option)
    //   # TODO
    //   # @click selector
    //   # element(By.cssContainingText('md-option', option)).click()

    expectValue(selector, value, wait) {
      this.waitFor(selector, wait);
      return test.expect.element(selector).value.to.contain(value);
    },

    expectText(selector, value, wait) {
      this.waitFor(selector, wait);
      return test.expect.element(selector).text.to.contain(value);
    },

    expectFlash(value, wait) {
      test.pause(1000);
      const selector = '.flash-root__message';
      this.waitFor(selector, wait);
      return test.expect.element(selector).text.to.contain(value);
    },

    expectNoText(selector, value, wait) {
      this.waitFor(selector, wait);
      return test.expect.element(selector).text.to.not.contain(value);
    },

    acceptConfirm() {
      test.acceptAlert();
      return this.pause();
    },

    signInViaPassword(email, password) {
      const page = pageHelper(test);
      if (email) { page.fillIn('.auth-email-form__email input', email); }
      page.click('.auth-email-form__submit');
      page.fillIn('.auth-signin-form__password input', password);
      return page.click('.auth-signin-form__submit');
    },

    signInViaEmail(email) {
      page.fillIn('.auth-email-form__email input', email);
      page.click('.auth-email-form__submit');
      page.click('.auth-signin-form__submit');
      page.expectText('.auth-complete', 'Check your email');
      page.loadPath('use_last_login_token');
      page.click('.auth-signin-form__submit');
      return page.expectFlash('Signed in successfully');
    },


    signUpViaEmail(email = "new@account.com") {
      const page = pageHelper(test);
      page.fillIn('.auth-email-form__email input', email);
      page.click('.auth-email-form__submit');
      page.fillIn('.auth-signup-form input', 'New Account');
      page.click('.auth-signup-form__legal-accepted .v-input--selection-controls__input');
      page.click('.auth-signup-form__submit');
      page.expectElement('.auth-complete');
      page.loadPath('use_last_login_token');
      return page.click('.auth-signin-form__submit');
    },

    signUpViaInvitation(name = "New person") {
      const page = pageHelper(test);
      page.click('.auth-email-form__submit');
      page.fillIn('.auth-signup-form__name input', name);
      page.click('.auth-signup-form__legal-accepted .v-input--selection-controls__input');
      return page.click('.auth-signup-form__submit');
    },

    waitFor(selector, wait = 8000) {
      if (selector != null) { return test.waitForElementVisible(selector, wait); }
    },

    waitForElementNotVisible(selector, wait = 8000) {
      if (selector != null) { return test.waitForElementNotVisible(selector, wait); }
    }
  };
};
