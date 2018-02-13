module.exports = {
  beforeEach: (test, done) => {
    test.resizeWindow(1600, 1000, done)
  },

  afterEach: (test, done) => {
    test.end()
    done()
  }
}
