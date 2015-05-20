
## How to contribute to Loomio (in 10 easy steps)

######1. Clone the loomio repository:

        git clone git://github.com/loomio/loomio.git

######2. Create an outbox branch with your Github account:

        cd loomio
        git remote add outbox git@github.com:your_github_handle/loomio.git

######3. Create a new branch for your feature:

        git checkout -b my-loomio-fix


######4. Code, Code, Code!
  
  * keep coding styles consistent with what you see already in the app, and with the conventions discussed below.
  * the more complex a PR, the more review and back-and-forth will be required to accept it. Keep it as simple and clean as possible!
  * write tests for your code and make sure they pass; you'll have a tough time convincing us to accept your PR without tests.

######5. Follow Coding Conventions:
  
  * Generally, the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide) is a good thing to be aware of.
  * we use x2 spaces, no tabs
  * please avoid introducing new 'rocket' hash syntax (this: `{ one: 'one' }` instead of this: `{ :two => 'two' }`)
  * please ensure there's no trailing whitespace at the end of lines (We quite like [this plugin](https://github.com/SublimeText/TrailingSpaces).)
  * Use brackets (`{...}`) for single line blocks, and `do ... end` for multi-line blocks.
  * Be wary of comments in code! Ruby is an expressive language; if you need to comment your code, you're likely either apologizing, or doing something too complex. (Often both!)
  * We'll be happy to discuss further style conventions as we review your PR.

######6. Commit

        git commit -m "Fix underline styling on discussion page title"
Please be sure to write a short, descriptive commit message. No empty commit messages!


######7. Fetch any changes which have happened upstream

  ```
  git fetch origin
  ```
This is to ensure there are no merge conflicts when it comes time to merge into `master`.

######8. Squash your commits into a single commit (for clean history buffs like us)

  ```
  git rebase origin/master -i
  ```
  (for more info on squashing, refer to [this handy guide](https://github.com/loomio/loomio/wiki/How-to-squash))

######9. Push to your forked version of loomio

  ```
  git push outbox my-loomio-fix
  ```

######10. Issue a Pull Request

  * Visit the github page for your forked version of Loomio (http://github.com/your_github_handle/loomio)
  * You'll likely see a big green 'Compare & Pull Request' button next to your new branch
  * If not, click on 'branches' and find your branch, then click 'Pull Request'
  * Sanity check that all of your changes are present, and no extra files or code has slipped in.
  * Be sure to write a brief but complete description of the changes you've made and why you've made them.
  * Once everything looks good, send your PR!

  From there, you'll likely get feedback from one or more of the Loomio core team. If we ask you to do more work, or make style changes, or refactor, don't get discouraged! We're curators, not gatekeepers, and are happy to engage in discussion (that's what Loomio's for anyway.)

  Happy coding, and we look forward to working together soon.