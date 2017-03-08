This page is a guide for people who would like to contribute translations to Loomio.

_If you're a developer, check out the [code guide](https://github.com/loomio/loomio/wiki/Translation-for-Developers)_

## Contents

1. [**Getting Started**](https://github.com/loomio/loomio/wiki/Translation#getting-started)
  1. join an existing language
  2. create a new language
  3. set a fall-back language (optional) 
2. [**How to translate**](https://github.com/loomio/loomio/wiki/Translation#how-to-translate)
  1. the basics
  2. more advanced translation
  3. working within a community of translators
3. [How to get translations up on Loomio.org](https://github.com/loomio/loomio/wiki/Translation#how-to-get-translations-up-on-loomioorg)
4. [Improving processes, giving feedback](https://github.com/loomio/loomio/wiki/Translation#improving-processes-giving-feedback)

---

**Links** - - {
[Email us](mailto: contact@loomio.org) } - {
[Loomio group](https://www.loomio.org/g/cpaM3Hsv/loomio-community-translation) } - {
[Transifex](https://www.transifex.com/projects/p/loomio-1/)  } - { 
[Twitter updates](https://twitter.com/search?f=realtime&q=%40loomio%20%23translation) } - -

---

## Getting Started

We use Transifex to manage our translation process (an excellent service that's free for open-source projects). As you follow the step below you'll be invited to set up an account.  

### + join an existing language

You can see the full list of languages underway on the [Loomio Transifex page](https://www.transifex.com/projects/p/loomio-1/)
Click "Help Translate Loomio" and ask to join a translation **[this needs some more detail]**

NB: Make sure you click 'Display all Languages' :  
[![image](https://cloud.githubusercontent.com/assets/2665886/4144368/73d5762a-33de-11e4-9c47-56838886b741.png)](https://www.transifex.com/projects/p/loomio-1/)


### + create a new language

Please check whether your language has been started before requesting a new one! (see above). 
Feel free to request a new language or dialect if it doesn't exist. 

If you're not sure or need help, please [email us](mailto:nati@loomio.org)


### + set a fall-back language (optional)

If a translation is missing in your language Loomio will 'fall back' to using English in that location (so that there is at least some text present).
If you would like to recommend a better fall-back language please [let us know](mailto:nati@loomio.org).

You can see Loomio's current fall-back settings at the bottom of this page : www.loomio.org/translation 


***

## How to translate 

Make sure you have either joined/ created a language (and have a Transifex account).

### + the basics

1. visit the [Loomio Transifex page](https://www.transifex.com/projects/p/loomio-1/), and click on your language
![image](https://cloud.githubusercontent.com/assets/2665886/4144134/84c438c2-33d9-11e4-9267-91e429e50409.png)

2. select the resource you want to translate
![image](https://cloud.githubusercontent.com/assets/2665886/4144159/08dd77f4-33da-11e4-8c49-7c7214865f7e.png)
 _(start with Main app resource, then move on to frontpage)_

3. click 'Translate'

4. (a) click on a phrases, 
(b) read the english text, 
(c) enter your translation, 
(d) save
[![image](https://cloud.githubusercontent.com/assets/2665886/4144302/df681dd6-33dc-11e4-9ff6-a6589c630631.png)](https://cloud.githubusercontent.com/assets/2665886/4144302/df681dd6-33dc-11e4-9ff6-a6589c630631.png)

**What to ignore**

Ignore anything in angle brackets or curly braces. E.g.:
```
<h2>Welcome</h2>
<p>
%{who} invited you to Loomio! 
<a href='%{link}'>Click here to visit %{group_name}!</a>
</p>
```

The `<h2>`, `<p>`, and `<a>` is html code (for heading, paragraph and link), so *they don't need to be translated*.

The text inside the `%{curly braces}` will get replaced by the software, so it's important to keep it unmodified.

### + more advanced translation

**- language style guide**
www.loomio.org/d/xDUZJPrp/language-style-guide-for-translators


### + working within a community of translators

As you translate, you might encounter questions like:
- should this use formal/ informal language ?
- who should I check this translation with ? 

In a lot of cases, it's best to work through these challenges with other translators in your language.

We are currently working with the community to figure out how best to support teams of translators to work together. Any input on this is welcome.
 
###

***

## How to get translations up on Loomio.org 

We deploy language updates at least once a week. <br/>
Watch [twitter @loomio #translation](https://twitter.com/search?f=realtime&q=%40loomio%20%23translation) for updates.

If you would like to see translations up faster, please tweet us or email [Nati](mailto:nati@loomio.org)

### + overview of whole translation process

![image](https://cloud.githubusercontent.com/assets/2665886/4211018/ab080ed2-387f-11e4-93f4-f53f673bad50.png)

context: [Github](https://github.com/loomio/loomio) is where the working code of Loomio is managed and deployed from.
 
1. Transifex grabs a copy of all the English phrases from Github (auotmatic)
2. Amazing community uses Transifex to translate all these phrases.
3. Mix imports all the new translations into Github, and checks to make sure nothing is broken.
4. We deploy translations to Loomio.org


![image](https://cloud.githubusercontent.com/assets/2665886/4201265/5b931404-381c-11e4-93ce-85339dd6761d.png)

*Mix wrangling code*



***

## Improving processes, giving feedback

If you would like to suggest an improvement, or have some feedback on the translation process, please feel free to start a discussion in the [Loomio group](https://www.loomio.org/g/cpaM3Hsv/loomio-community-translation), or email Nati at nati@loomio.org  
