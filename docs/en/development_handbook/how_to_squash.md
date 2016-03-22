Here's more detail on how to rebase and squash a bunch commits once your pull request is ready to go.

## Merge squash

1. Checkout master and make sure it is up to date
```
git checkout master
git pull origin master
```

3. Checkout a new branch called squash
```
git checkout -b squash
```
4. Merge your feature branch into the squash branch (the branch you are currently on) and squash the commits. Assuming the feature branch you've been working on is called `cool-button` this command would be:
```
git merge cool-button --squash
```
5. Resolve any merge conflicts, then add and commit any changes (`git add .` and `git commit -m "commit-message"`). If there are no merge conflicts you will see the message:
```
Automatic merge went well; stopped before committing as requested
```
...run `git commit -m` and provide a commit message for the squash.

At this point it might be useful to rename the branches. e.g.
```
git branch -m cool-button cool-button-old
```
So now there is no branch called cool-button, just squashed-cool-button and cool-button-old. So we can renamed the squashed branch to the original branch name: 

```
git branch -m cool-button

```
You can now push your changes up to the intended remote repository, e.g.
```
git push origin cool-button
```

If you've previously pushed the unsquashed version, you will have to force the update
 
```
git push origin cool-button -f
```
