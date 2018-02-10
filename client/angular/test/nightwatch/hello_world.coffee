module.exports = (test) ->
    test.url("http://localhost:3000/dashboard")
        .waitForElementVisible('.dashboard-page', 2000)
        .end()
