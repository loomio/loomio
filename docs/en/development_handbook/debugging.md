stub article:
  Checking the network requests in chrome
  Console logging what you're looking at

debugging protractor e2es

Working out why a test failed can be really frustrating and time consuming.

Use `fit` rather than `it` to isolate a particular test so it's faster to run.

If you can't tell what is going on.. you can add "sleeps" into the test to give yourself more time to understand and even interact with the browser in test.

```
browser.driver.sleep(5000);
```
