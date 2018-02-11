module.exports = {
  beforeEach: (test, done) => {
    test.resizeWindow(1280, 800, done)
  },

  afterEach: (test, done) => {
    test.end()
    done()
  }
}
