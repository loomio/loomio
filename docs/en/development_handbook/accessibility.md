## We're developing Loomio to be accessible to people who are blind.

Recently we started a collaboration with [David Best](http://davidbest.ca/), whose experience as a web developer and a blind individual has been invaluable in teaching us how to make Loomio work for people how are navigating the web without vision.

We're developing guidelines specifically for the Loomio codebase. Please note none of this has been verified yet: while it may be a useful resource for your development project, please consult with a professional if you want to guarantee accessibility.

## Guidelines

###  Being descriptive with `title` and `alt`

The most basic place to start is to add `title`s to links, and `alt`s to images:

So instead of `<a href: '/dashboard'>`, we use `<a href: '/dashboard', title: "Dashboard">`.

(At the same time as we’re doing accessibility improvements, we’re also trying to support [33 languages](https://www.loomio.org/translation), so in reality instead of just plopping a string in like ‘Dashboard’, we would actually pass it to the translate filter.)

### Indicate whether an element displays pop-up content with `aria-haspopup` and `aria-collapsed`

The `aria-haspopup` element indicates that an element has a pop-up menu or sub-level menu (a group of items that appear on top of the main page content). This means that activating the element (via a click, for example) renders additional content.

Additionally, you can add an `aria-expanded` element to indicate whether the pop-up content is expanded or collapsed. The value of `aria-expanded` should be true when the pop-up element is visible, and false when it is not.

### Distinguishing between the visual and audio

As a rule, the user experience for people who are blind should follow as closely as possible to that for sighted people.

Occasionally though, we need to provide different experiences. To do that we use `.sr-only` and `aria-hidden`.

`.sr-only` is a Bootstrap class that includes text for screen readers but hides it from other devices.

For the reverse case, where we want to hide something from screen readers, we use `aria-hidden: ‘true’`.

So for example, on most devices, the Notifications menu is indicated by a bell icon. Icons are a purely visual indicator though, so for screenreaders we use a string of text instead:

```
<div class="sr-only">Notifications</div>
<i class="fa-bell" aria-hidden="true"></i>
```

Where possible, we also try to exclude HTML elements that add unnecessary confusion to the screen reader experience, such as `<nobr>`.

### Using headings for hierarchy

There’s some debate over the most accessibility strategy for handling headings in web apps. Ideally, every page should have a single H1, with nested H2’s, H3’s, H4’s underneath it in a logical tree structure.

This is easy to do on a static document, but more complex in a web app because we want to distinguish chrome from content. We're still settling on the best solution for Loomio.

At a bare minimum standard, every page must have an H1. When a user jumps to the H1, they should know what page they are on, and be positioned at the top of the main content.

### Breaking up the page into regions

In addition to headings, we use regions to break the page into logical sections.

[ARIA defines special roles](http://www.webteacher.ws/2010/10/14/aria-roles-101/) for common regions, like 'main' 'search', 'navigation', etc.

In practice, that means `<div class=".lmo-navbar-search">` has been replaced with `<div class=".lmo-navbar-search
" aria-role="search">`.

HTML5 defines a some more useful regions too, like `section` and `article`. So for instance with HTML5 you can use `<section>` instead of `<div aria-role="section">`.

**Every region needs a label.**

When you're navigating with a screenreader, the label is read out as you hit each region.

If the heading is visible on screen, we use `aria-labelled-by` and pass in the id of the label:

```
<section class="proposals-card" aria-labelled-by="proposals-card-heading">
 <h2 class="card-title" id="proposals-card-heading">Proposals</h2>
```

If the heading is not visible, we use `aria-label` instead, passing in a string:

`<section class="thread-group" aria-label: "Thread group">`

### Using focus to draw attention to modals and popups

Modals should have a header with an h1. When a modal or popup is launched, the focus should be transferred to the modal h1. Use an `aria-label` to define a string that labels the modal.

### Color contrast

The WCAG standards specify the required contrast ratio to ensure your text is legible.

In Loomio there are two background colors, one for the page (we’re using a light grey #ebebeb), and one for the cards (we’re using white #fff). Our primary text color is near black (#262626), which has a really high contrast.

However, there are parts of the app where we want text to be de-emphasised, e.g. on a timestamp. This lower-priority text still needs to be legible, so we used the [WebAIM contrast checker](http://webaim.org/resources/contrastchecker/) to find the right colors. In the end we settled on one grey to be used on the white card background and a slightly darker grey to be used on the light grey page background.

We have these colors defined in mixins.scss.

![Colors used in Loomio](http://i.imgur.com/dRFmrET.png)

### Everything interactive should probably be a form
### Links + Buttons
### Live updates/alerts/focus on page load
### Stuff we get from Bootstrap for free

## Testing

If you are developing for accessibility, you should try using the web with a screenreader. Screenreaders read out what's on the screen, translating the two-dimensional visual experience into a linear audio experience.

If you're on OSX, CMD+F5 opens [VoiceOver](https://www.apple.com/nz/accessibility/osx/voiceover/), the built-in screenreader. Probably the 'best in class' screenreader is [JAWS](http://www.freedomscientific.com/Products/Blindness/JAWS) (Windows only). There are many free alternatives too, e.g. browser plugins.
## Partners

The funding for this work has come from a crowdfunding campaign and a generous grant from the [Namaste Foundation](http://www.namaste.org/blog/collaborative-decision-making-with-loomio). We also work with accessibility consulting firms [U-R-Able](http://u-r-able.com) in North America and [AccEase](http://www.accease.com/) in New Zealand.
