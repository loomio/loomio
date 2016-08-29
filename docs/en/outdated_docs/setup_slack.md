Setting up a slack integration to notify you and your team of new events in Loomio is easy. Here are the steps:

- Visit `https://<your-team-name>.slack.com/services/new/incoming-webhook/`
- Select the channel you'd like the posts to go into, and click 'Add Incoming Webhooks Integration'
- Find the 'Webhook URL' on the resulting page; it should start with `https://hooks.slack.com/`. Copy this value to your clipboard.
- Enter the rails console (`rails c`, or, in an instance running on heroku, `heroku run rails c`), and create a new webhook object, like so:
```
Webhook.create! hookable: Group.find_by(name: "My group name"), 
                uri: "<webhook uri>", 
                kind: :slack, 
                event_types: ['new_motion', 'motion_closing_soon']
```

In order, these fields are:
- __hookable__: A group or discussion which will publish its events to the slack channel (NB: subgroups which are visible to their parent will also publish their events to this channel.)
- __uri__: The slack uri provided in the previous steps
- __kind__: Always set this to ':slack' for a slack integration (other integrations coming soon!)
- __event_types__: Specifies which types of events will be published. Currently available events are:
  - new_motion
  - motion_closing_soon
  - motion_outcome_created
  - motion_outcome_updated
  - (more on the way)

Also, note that there's no limit to the number of webhooks you can create with a single incoming webhook uri, so it's possible to create a slack channel which receives events from several groups or discussions at once.
