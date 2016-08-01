# [WIP] QA Process

Please feel free to add stubs or github comments if you think of something that is missing.

## Self test
As you build stuff, you tend to test it yourself unless you're Chuck Norris.

## Smoke testing
Smoketest - someone other than the developer tests that the functionality works as expected.

Ask other team members to test the feature out. Usually you'll deploy the feature to loomiotest.org and create a list of instructions about what to do, pop them in a proposal and people will report back on their experience.

## Code checklist

### Accessibility
- images have ALT attribute describing the image
- links have TITLE attribute naming the target page
- correct usage of heading tags (h1 should exist and subsequent levels should not be skipped)
- aria label used where layout rather than text indicates grouping.
- Use a screenreader to navigate through the feature and confirm you can complete the task.

### Translations
- All natural language (English) is abstracted into client.en.yml or server.en.yml

## Browser compatibility

At a minimum please test the following browser, device combinations

- macosx: chrome, firefox, safari
- windows: ie 11, firefox, chrome
- android: default android browser, chrome, firefox if you like
- iphone: safari

## Email client compatibility
If you've modified/created email in your feature you need to test that they render correctly in
- desktop: Gmail, Google Inbox
- Mobile gmail, inbox
- we should test microsoft outlook but I don't know how we'd do that.

## Production readyness
deploy to loomioclone, this environment includes intercom and google analytics and ahoy and other things that exist on production but not development. confirm everything works as expected in this environment.
