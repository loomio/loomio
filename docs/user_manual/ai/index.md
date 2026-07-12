# Using AI with Loomio

AI can help you read a long conversation, identify questions that still need attention, and prepare a possible next step. Loomio supports two ways to use it.

In both cases, you remain responsible for the conversation. Review an AI's summary against the thread, especially where it describes agreement, objections, or people who have not participated. Do not let an AI post, create a poll, change a vote, invite someone, or record an outcome unless you have reviewed and approved that action.

## Copy a thread into an AI assistant

Use this when you want to ask an AI assistant a question yourself.

1. Open the thread in Loomio.
2. In the right sidebar, choose **Copy for AI**, below **Print**.
3. Copy the facilitation prompt, then copy the complete thread transcript.
4. Paste both into your preferred AI assistant and ask it for help.

The prompt asks the AI to read Loomio's facilitation guidance, including [9 ways to use a Loomio proposal to turn a conversation into action](https://www.loomio.com/blog/2015/09/18/9-ways-to-use-a-loomio-proposal-to-turn-a-conversation-into-action/). It then asks the AI to identify the purpose of the thread, areas of agreement, unanswered questions, concerns or objections, participation still needed, and a suitable way to move forward.

**Copy for AI** creates one Markdown document containing the complete thread. It is available to thread members. Copying does not send the text to an AI service; pasting it into an external assistant does. Consider the thread's privacy, the people involved, and the terms of the service you choose before pasting it there.

## Connect an AI agent to Loomio

Use this when you work with a desktop or coding agent that can install skills and call APIs. The agent can read Loomio on your behalf using your account's API key, subject to the same Loomio permissions that apply to you.

Give the agent this URL:

```
https://www.loomio.com/skills/loomio-facilitator/SKILL.md
```

Then use a prompt such as:

```
Use the Loomio facilitator skill. Read the relevant Loomio thread and tell me what has been decided, whose concerns need attention, and which facilitation pattern would help us move forward. Do not post or create anything without my approval.
```

The current agent API can list threads you can access and read their items or a complete Markdown version. Further capabilities, including notifications, preferences, votes, outcomes, templates, and membership management, are being added incrementally.

## Keep control of your account

An API key acts as you. Keep it in the agent's private configuration, never in a shared prompt, Loomio comment, document, or source repository. Rotate the key if it may have been exposed.

The facilitator skill is designed to read before recommending action. It distinguishes visible vote reasons and objections from ordinary disagreement, does not infer identities in anonymous polls, and asks you to confirm before it writes anything.

## Choosing a next step

An AI can suggest several useful patterns:

- Test apparent agreement with a clear proposal
- Surface competing ideas when the group is split
- Break a complex issue into smaller decisions
- Invite quieter members to respond
- Use a time-bound engagement check for a required action
- Ask for volunteers to take a practical next step
- Record an outcome that states what was decided, outstanding concerns, owners, and a review date

These are suggestions, not a substitute for facilitation. The people affected by a decision should have the opportunity to contribute in the way your group has agreed.
