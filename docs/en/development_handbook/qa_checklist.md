# [WIP] QA Process

Please feel free to add stubs or github comments if you think of something that is missing.

## Self test
As you build stuff, you tend to test it yourself unless you're Chuck Norris.
You should have unit tests and some e2e tests which pass too.

## Code review

### Accessibility
- images have ALT attribute describing the image
- links have TITLE attribute naming the target page
- correct usage of heading tags (h1 should exist and subsequent levels should not be skipped)
- aria label used where layout rather than text indicates grouping.
- Use a screenreader to navigate through the feature and confirm you can complete the task.

Please read the [a11y guide](accessibility.md) because it covers this in much better detail.

### Translations
- All natural language (English) is abstracted into `client.en.yml` or server.en.yml

More detail about how to write Loomio app code in [Code guidelines](code_guidelines.md).

### Images
- All images should have sizes specified by CSS
- Images should have twice as many pixels as specified by their CSS size so that they don't look blurry on retina.
- Check that images are the right size for the job.

## Smoke testing and compatibility
Smoketest - someone other than the developer tests that the functionality works as expected.

Ask other team members to test the feature out. Usually you'll deploy the feature to loomiotest.org and create a list of instructions about what to do, pop them in a proposal and people will report back on their experience.

A general proposal might be:
> Please test the feature as thoroughly as you can. When responding please say what browser and device type you are using. If you see something that looks wonky please take a screenshot and attach it to a comment, with a short expaination of what did prior and what you were expecting.

As the test progresses you'll need to confirm that all our supported platforms have had testing, maybe mentioning people who have the untested device and asking them to help.


## Browser compatibility

At a minimum please test the following browser, device combinations

- macosx: chrome, firefox, safari
- windows: ie 11, firefox, chrome
- android: default android browser, chrome, firefox if you like
- iphone: safari

[Browserling](https://www.browserling.com) is great. You should use it to test platforms you don't have ready access to.

Test webpage responsiveness with your desktop browser. You can use your browser dev tools to simulate mobile devices.

## Email client compatibility
If you've modified/created email in your feature you need to test that they render correctly in
- desktop: Gmail, Google Inbox
- Mobile gmail, inbox
- we should test microsoft outlook but I don't know how we'd do that.

## Production readyness
deploy to loomioclone, this environment includes intercom and google analytics and ahoy and other things that exist on production but not development. confirm everything works as expected in this environment.
