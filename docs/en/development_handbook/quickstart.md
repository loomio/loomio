### Loomio Development Quickstart

1. Clone and move to the repo.
```
git clone git@github.com:loomio/loomio.git && cd loomio
```
2. Run the bootstrap task
```
rake bootstrap
```
_NB: Take note of the email and password generated at the end of this task; you'll need it to log in once setup is complete_

3. Build the angular frontend
```
cd angular && gulp compile
```
4. Launch the server
```
rails s
```

##### Other things to know
- There are several other gulp commands you can run to make your development go. These can be run from the `angular` folder.
  - `gulp dev`: Automatically rebuild the javascript app as you make changes
  - `gulp protractor`: Run the automated frontend tests
  - `gulp protractor:now`: Rebuild the javascript app, then run the automated frontend tests

For more advanced development setup, or if you're having trouble, check out the [advanced guide](advanced_setup.md).
