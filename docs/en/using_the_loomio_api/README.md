# Using the Loomio API

Interested in interacting with Loomio from outside of Loomio? Awesome, you're in the right place!

This is intended to be a comprehensive reference of what's possible with the Loomio API. It's very much a work in progress at the moment.

NB: All of the curl commands in this document have been shortened for readability. IE, a curl command like this:

```bash
  curl /discussions.json
```

actually, of course, means this:
```bash
  curl http://www.loomio.org/api/v1/discussions.json?access_token=<access_token>
```

Happy cUrling and bashing!

## Using the Public API

Data in public discussions is freely available via the Loomio API. Certain endpoints (marked with a 🔓 in the [API Endpoints](#api_endpoints) section below) are accessible even while logged out. For example, you can view a list of the most recently created public discussions on [Loomio.org](http://www.loomio.org) like so:

```bash
  curl /discussions.json
```

## Getting an OAuth application set up

Need access to private user data? You'll need to set up an OAuth application to authenticate yourself. Have a look at [Creating an OAuth Application](TODO) for further instructions.

## API Response Information

#### Side loading

Responses from the Loomio API all utilize a strategy known as [side loading](https://www.netguru.co/blog/active-model-serializers-ember) (also known as 'compound document')

This means that instead of loading all records in a nested structure, like this:

```json
# NB: Not what actually happens:
# GET api/v1/discussions/1
{
  "id": 1,
  "title": "My awesome discussion",
  "group": {
    "id": 2,
    "name": "My awesome group"
  }
}
```

we load all of the records in the response in a flat structure, side by side, like so:
```json
{
  "discussions": [
    {
      "id": 1,
      "title": "My awesome discussion",
      "group_id": 2
    }
  ],
  "groups": [
    {
      "id": 2,
      "name": "My awesome group"
    }
  ]
}
```

This makes it really easily to import records into a clientside record store (which is what we do with them), but can mean it's a little trickier to extract a particular record from a response.

```ruby
# getting a single discussion
response = RestClient.get('api/v1/discussions/1.json')
console.log response['discussions'][0]
# => { id: 1, title: "My awesome discussion", group_id: 2 }
console.log response['groups'][0]
# => { id: 2, name: "My awesome group" }
```

```ruby
# getting a list of discussions
response = RestClient.get('api/v1/discussions.json')
console.log response['discussions']
# => [
#     { id: 1, title: "My awesome discussion", group_id: 2 },
#     { id: 2, title: "My other discussion", group_id: 3 }
#    ]

console.log response['groups']
# => [
#     { id: 2, name: "My awesome group" },
#     { id: 3, name: "My other group" }
#    ]
```

#### Error handling

When something goes wrong, we'll do our best to let you know why.
All errors will come back with an appropriate response code
(accessible via the `status` field), and an exception message:

```ruby
  response = RestClient.get('api/v1/discussions/not_found.json')
  console.log response['exception'] if response.status == 404 # => "Resource not found"
```

Possible errors include:

**400 - Bad request**
The request was malformed or missing required values; check your parameters and try again.

**403 - Unauthorized**
You do not have permission to perform this action with the supplied credentials.
Check that your application has the correct permissions and try again.

**404 - Resource Not Found**
The requested resource could not be found; it may have been deleted or moved.

**418 - I'm a Teapot**
Something has gone horribly wrong and you have [confused Loomio with a teapot](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#418).

**422 - Unprocessable Entity**
The form values submitted with this request could not be properly processed
(ie, they were missing some required fields, or there were other validations errors)
Try checking the form and resubmitting.

**429 - Too many requests**
You (or someone like you) has been hitting the API a _little_ too hard recently. Take a break and try again later. (TODO: implement and document a simple rate limiting system for the API)

**500 - Internal Server Error**
Something went wrong on our end, whoops! We'd really appreciate you letting us know
by sending an email to [contact@loomio.org](mailto:contact@loomio.org) or [filing an issue](http://github.com/loomio/loomio/issues)

## API Endpoints

#### General Knowledge

There are two main types of endpoint -- ones which return a single record, and ones which return a collection of records, each with their own standardized sets of parameters.

###### Individual record parameters
`show`, `update`, and `destroy`, as well as other member endpoints, *require* an id parameter to specify which record is operated in. This can be either in the format of the record id, or the record key.

```bash
  # GET a discussion by id
  curl /discussions/1.json
```
or,
```bash
  # UPDATE a discussion by key
  curl -x PUT --data "title":"Let's go to the moon!" /discussions/UlXZMHwE.json
```

###### Collection record parameters
`index` and other collection endpoints accept a series of parameters for specifying the timeframe and pagingation of the records which are returned. They're outlined below:

**from**: The number of records to skip in the collection returned (default is 0)
```bash
  # GET all discussions except for the first 10
  curl "/discussions.json?from=10"
```

**per**: The number of records to return in the collection (default is 50)
```bash
  # GET the first 10 discussions
  curl "/discussions.json?per=10"
```

**since**: Filter records which have occurred after the given date (defaults to long, long ago)
```bash
  # GET all discussions created in 2016
  curl "/discussions.json?since=Fri Jan 1 2016"
```

**until**: Filter records which have occurred before the given date (defaults to way in the future)
```bash
  # GET all discussions created before 2016
  curl "/discussions.json?until=Fri Jan 1 2016"
```

**timeframe_for**: Specify which field to apply the previous timeframe values to. Accepts any datetime field (the ones ending in `_at`), defaults to `created_at`
```bash
  # GET all discussions with activity in 2016
  curl "/discussions.json?timeframe_for=last_activity_at&since=Fri Jan 1 2016"
```

These can also be combined:
```bash
  # GET records 10 - 20 which have been updated in 2011
  curl "/discussions.json?from=10per=10&timeframe_for=updated_at&since=Thu Jan 1 2011&until=Fri Jan 1 2012"
```

These options are further documented in the [README](http://github.com/loomio/snorlax) for the snorlax gem which Loomio uses to serve API requests

#### Users
**Example JSON for a user**:
```json
{
  # Basics
  "id": "",
  "key": "",
  "name": "",
  "username": "",
  "label": "",

  # Locale info
  "locale": "",
  "time_zone": "",

  # Avatar info
  "avatar_kind": "",
  "avatar_initials": "",
  "avatar_url": "",
  "profile_url": ""
}
```

#### Memberships
**Example JSON for a membership**:
```json
{
  # Basics
  "id":                      "The memberships's id (integer)",
  "admin":                   "Whether the user is an admin or not (boolean)",
  "volume":                  "The volume the user has set for updates from this group (string)",

  # Relationships
  "group_id":                "The id of the group the membership belongs to (integer, Group)",
  "user_id":                 "The id of the user the membership belongs to (integer, User)",
  "inviter_id":              "The id of the user who invited this user to the group (integer, User)"
}
```

#### Groups
**Example JSON for a group**:
```json
{
  # Basics
  "id":                      "The group's id (integer)",
  "key":                     "The group's key (string)",
  "name":                    "The group's name (does not include parent group name) (string)",
  "full_name":               "The group's full name (including parent group name) (string)",
  "description":             "The group's description (string, markdown)",

  # Relationships
  "creator_id":              "The user who created the group (integer, User)",
  "cohort_id":               "The cohort this group belongs to (cohorts are semi-weekly chunks of groups used for analytics, integer, can be null)",
  "parent_id":               "The id of this group's parent (integer Group, can be null)",

  # Relationship counts
  "memberships_count":       "The total number of memberships (and thus members) in the group (integer)",
  "invitations_count":       "The total number of invitations to this group (integer)",
  "discussions_count":       "The total number of discussions in the group (integer)",
  "public_discussions_count":"The total number of public discussions in the group (integer)",  
  "motions_count":           "The total number of proposals raised in this group (integer)",
  "has_custom_cover":        "Whether the group has uploaded a custom photo or not (boolean)",
  "has_multiple_admins":     "Whether the group has multiple admins or just one (boolean)",

  # Dates
  "archived_at":             "The date this group was archived (datetime, can be null)",
  "created_at":              "The date this group was created (datetime)",

  # Images
  "logo_url_medium":         "The absolute url of the group logo (string)",
  "cover_url_desktop":       "The absolute url of the group cover photo (string)",

  # Privacy / permissions
  "group_privacy":                "The group's privacy, (open / closed / secret) (string)",
  "discussion_privacy_options":   "The possible levels of privacy for discussions in this group (public_only / private_only / public_or_private) (string)",
  "is_visible_to_parent_members": "Whether a subgroup can be viewed by members of it's parent (boolean)",
  "members_can_add_members":      "Whether group members are able to add other members (boolean)",
  "members_can_create_subgroups": "Whether group members are able to create subgroups (boolean)",
  "members_can_start_discussions":"Whether group members can start discussions (boolean)",
  "members_can_edit_discussions": "Whether group members can edit discussions (boolean)",
  "members_can_raise_motions":    "Whether group members can raise motions (boolean)",
  "members_can_vote":             "Whether group members can vote (boolean)",
  "members_can_edit_comments":    "Whether group members can edit comments (boolean)",
  "membership_granted_upon":      "How members are able to join the group (request / approval / invitation) (string)",
  "parent_members_can_see_discussions": "Whether members of the parent group are able to see discussions in this subgroup (boolean)",

  # Deprecated
  "organisation_id":         "The id of the parent group of this organisation (equal to id if this group is a parent) (integer) (DEPRECATED)",
  "is_subgroup_of_hidden_parent": "Whether the parent group is secret (boolean) (DEPRECATED)",
  "has_discussions":              "Whether the group has discussions or not (boolean) (DEPRECATED)",
  "visible_to":                   "Not the droids you're looking for (string) (DEPRECATED)",
}
```

#### Invitations
**Example JSON for an invitation**:
```json
{
  # Basics
  "id":                     "The id of the invitation (integer)",
  "recipient_name":         "The name of the invitation recipient (string, can be null)",
  "recipient_email":        "The email of the invitation recipient (string, can be null)",

  # Relationships
  "group_id":               "The group the invitee is being invited to (integer Group)",
  "inviter_id":             "The user who is making the invitation (integer User)",

  # Invitation url  
  "token":                  "The unique token used to authorize this invitation (string, can be null)",
  "url":                    "The full invitation url including the above token (string, can be null)",
  "single_use":             "Whether the invitation can be used multiple times (boolean)",

  # Dates
  "accepted_at":            "When the invitation was accepted (datetime, can be null)",
  "cancelled_at":           "When the invitation was cancelled (datetime, can be null)",
  "created_at":             "When the invitation was created (datetime)",
  "updated_at":             "When the invitation was updated (datetime)"
}
```

#### Membership Requests
**Example JSON for a membership request**:
```json
{
  # Basics
  "id":                     "The id of the membership request (integer)",
  "name":                   "The name of the requestor (string)",
  "email":                  "The email of the requestor (string)",
  "introduction":           "The text entered as an introduction (string)",
  "response":               "The response of the group member who accepted/rejected the request (string, can be null)",

  # Relationships
  "group_id":               "The group the user is requesting membership to (integer Group)",
  "responder_id":           "The id of the user responding to the request (integer User, can be null)",
  "requestor_id":           "The id of the user requesting membership (integer User, can be null)",

  # Dates
  "created_at":             "When the request was created (datetime)",
  "responded_at":           "When the request was responded to (datetime, can be null)",
  "updated_at":             "When the request was updated (datetime)"
}
```

#### Discussions

**Example JSON for a discussion**:
```json
{
  # Basics
  "id":                       "The discussion's id (integer)",
  "key":                      "The discussion's key (string)",
  "title":                    "The discussion's title (string)",
  "description":              "The discussion's description (string)",
  "private":                  "Whether the discussion is marked as private (boolean)",

  # Relationships
  "author_id":                "The id of the discussion author (integer, User)",
  "group_id":                 "The id of the group the discussion belongs to (integer, Group)",
  "active_proposal_id":       "The id of the current active proposal in the discussion (integer, Proposal)",

  # Relationship counts
  "items_count":              "The number of events associated with this discussion (integer)",
  "salient_items_count":      "The number of salient events associated with this discussion (integer)",
  "comments_count":           "The number of comments in the discussion (integer)",
  "first_sequence_id":        "The sequence_id of the first event in the discussion (integer)",
  "last_sequence_id":         "The sequence_id of the last event in the discussion (integer)",

  # Dates
  "last_activity_at":         "The last time there was event activity in the thread (datetime, can be null)",
  "created_at":               "The time the discussion was created (datetime)",
  "updated_at":               "The time the discussion was updated (datetime, can be null)",
  "archived_at":              "The time the discussion was archived (datetime, can be null)",

  # Discussion reader basics
  "discussion_reader_id":     "The id of the reader for this discussion and the logged in user (integer, can be null)",
  "discussion_reader_volume": "The volume of the discussion to the current user (string, can be null)"


  # Discussion reader counts
  "read_items_count":         "How many events the current user has read (integer, can be null)",
  "read_comments_count":      "The number of comments the current user has read (integer, can be null)",
  "read_salient_items_count": "How many salient events the current user has read (integer, can be null)",
  "last_read_sequence_id":    "The sequence_id of the last read event (integer)",
  "last_read_at":             "The last time the current user read this discussion (datetime, can be null)",
}
```

**A note about salient items**:

**A note about discussion readers**:

**Index**
Returns a list of discussions, which can be constrained by a group id

Parameters: regular [collection endpoint parameters](somewhere)

example:

```ruby
response = RestClient.get('loomio.org/api/v1/discussions.json')
```

#### Proposals
**Example JSON for a proposal**:
```json
{
  # Basics
  "id":                       "The id of the proposal (integer)",
  "key":                      "The unique key of the proposal (string)",
  "name":                     "The name of the proposal (string)",
  "description":              "The description of the proposal (string)",
  "outcome":                  "The outcome of the proposal (string, can be null)",

  # Relationships
  "group_id":                 "The group the proposal belongs to (integer Group)",
  "discussion_id":            "The discussion the proposal belongs to (integer Discussion)",
  "author_id":                "The author of the proposal (integer User)",
  "outcome_author_id":        "The author of the proposal's outcome (integer User, can be null)",

  # Relationship counts
  "activity_count":           "The number of activity items associated with this proposal (integer)",
  "non_voters_count":  "The number of members who have not voted (integer)",
  "vote_counts": {
    "yes":                    "The number of 'yes' votes on the proposal (integer)",
    "abstain":                "The number of 'abstain' votes on the proposal (integer)",
    "no":                     "The number of 'no' votes on the proposal (integer)",
    "block":                  "The number of 'block' votes on the proposal (integer)"
  },

  # Dates
  "closed_at":                "When the proposal closed (datetime, can be null)",
  "closing_at":               "When the proposal is set to close (datetime)",
  "created_at":               "When the proposal was created (datetime)",
  "updated_at":               "When the proposal was updated (datetime)",
  "last_vote_at":             "When the most recent vote on the proposal occurred (datetime, can be null)"
}
```

#### Votes
**Example JSON for a vote**:
```json
{
  # Basics
  "id":                       "The id of the vote (integer)",
  "position":                 "The position of the vote (yes / no / abstain / block) (string)",
  "statement":                "The statement accompanying the vote (string, can be null)",

  # Relationships
  "proposal_id":              "The proposal this vote was made on (integer Proposal)",
  "author_id":                "The user who made this vote (integer User)",

  # Dates
  "created_at":               "When this vote was made (datetime)"
}
```

#### Did Not Votes
(A 'did not vote' is a vote from a person who was able to vote on a proposal before it closed, but did not.)
**Example JSON for a did not vote**:
```json
{
  # Basics
  "id":                       "The id of the not-vote",

  # Relationships
  "proposal_id":              "The proposal this not-vote was made on (integer Proposal)",
  "user_id":                  "The user who made this not-vote (integer User)",

  # Dates
  "created_at":               "When this not-vote was created (datetime)"
}
```

#### Comments
**Example JSON for a comment**:
```json
{
  # Basics
  "id":                       "The id of the comment (integer)",
  "body":                     "The text of the comment (string)",

  # Relationships
  "author_id":                "The person who made this comment (integer User)",
  "discussion_id":            "The discussion this comment was made in (integer Discussion)",
  "liker_ids":                "The ids of all users who liked this comment ([integer], User)",
  "attachment_ids":           "The ids of all attachments to this comment ([integer], Attachment)",
  "parent_id":                "The id of the parent comment to this one (integer Comment, can be null)",
  "parent_author_name":       "The name of the parent comment's author (string, can be null)",
  "mentioned_usernames":      "A list of usernames mentioned in this comment ([string])",

  # Relationship counts
  "versions_count":           "The number of previous versions (edits) to this comment (integer)",

  # Dates
  "created_at":               "When this comment was created (datetime)",
  "updated_at":               "When this comment was last updated (datetime)",
}
```

#### Attachments
**Example JSON for an attachment**:
```json
{
  # Basics
  "id":                       "The id of this attachment (integer)",
  "filename":                 "The original filename of this attachment (string)",
  "filesize":                 "The size, in bytes, of this attachment (integer)",
  "filetype":                 "The extension associated with this attachment (string)",
  "is_an_image":              "Whether the attachment has one of the following extensions: [jpg jpeg png gif] (boolean)",

  # Relationships
  "author_id":                "The id of the user to create this attachment (integer User)",
  "comment_id":               "The id of the comment this is attached to (integer Comment)",

  # Images
  "original":                 "The absolute url of the full-sized attachment (string)",
  "thread":                   "The absolute url of the thread-sized (600px max width) attachment (string, can be null)",
  "thumb":                    "The absolute url of the thumbnail (100x100px) attachment (string, can be null)",

  # Dates
  "created_at":               "When the attachment was created (datetime)"
}
```

#### Events
**Example JSON for an event**:
```json
{
  # Basics
  "id":                       "The id of the event (integer)",
  "kind":                     "The kind of event (see below for full list of kinds) (string)",
  "sequence_id":              "The sequence id of the event if it is a thread item (integer, can be null)",

  # Relationships
  "actor_id":                 "The user who enacted this event (integer User)",
  "comment_id":               "The comment this event is associated with (integer, can be null)",
  "discussion_id":            "The discussion this event is associated with (integer, can be null)",

  # Dates
  "created_at":               "When this event was created (datetime)"
}
```

#### Notifications
**Example JSON for a notification**:
```json
{
  # Basics
  "id":                       "The id of this notification (integer)",
  "viewed":                   "Whether this notification has been seen by the current user or not (boolean)",

  # Relationhips
  "event_id":                 "The event associated with this notification (integer Event)",

  # Dates
  "created_at":               "When this notification was created (datetime)"
}
```

#### Drafts
**Example JSON for a draft**:
```json
{
  # Basics
  "id":                       "The id of this draft (integer)",
  "payload":                  "A JSON dump of information for this draft (see below for more detail) ( json)",

  # Relationships
  "draftable_id":             "The id of the draftable (User, Group, Discussion, or Poll) the draft is associated with (integer)",
  "draftable_type":           "The type of draftable (User / Group / Discussion / Poll) (string)"
}
```

#### Versions
**Example JSON for a version**:
```json
{
  # Basics
  "id":                       "The id of this version (integer)",
  "changes":                  "A JSON dump of changes made in this draft (see below for more detail) (json)",

  # Relationships
  "discussion_id":            "The discussion this is a past version of (integer Discussion, can be null)",
  "proposal_id":              "The proposal this is a past version of (integer Proposal, can be null)",
  "comment_id":               "The comment this is a past version of (integer Comment, can be null)",
  "previous_id":              "The id of the Version which was current before this one (integer Version, can be null)",
  "whodunnit":                "The id of the user made these changes (integer User, can be null)",

  # Dates
  "created_at":               "When this version was created (datetime)"
}
```

#### Search Results
(A Search Result is another way of representing a thread which has been returned from a search query)
**Example JSON for a search result**:
```json
{
  # Basics
  "id":                       "A random unique string to associate with this search result (string)",
  "key":                      "The key of the thread for this search result (string)",
  "query":                    "The query used to search for this result (string)",
  "title":                    "The title of the discussion (string)",
  "blurb":                    "A blurb of content from the discussion (string)",
  "description":              "The description of the discussion (string)",
  "result_group_name":        "The name of the group this discussion is in",
  "rank":                     "The weight given to this search result by the search algorithm (higher is more relevant) (float)",

  # Dates
  "last_activity_at":         "The last time this discussion had activity in it (datetime)"
}
```
