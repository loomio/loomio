# Matrix integration

Loomio can send notifications into your Matrix channels when new discussions, proposals, comments, votes, and outcomes occur. 

Matrix is nice because it allows some HTML in the chatroom, and Loomio takes advantage of this.

Our Matrix integration is a little different to our other chat integrations - it does not use a webhook - we've built a custom bot client for this one.

You will need to create a matrix user for the bot to login as.

Once you've created a user for the bot, sign in at that user to obtain the following information.

We're using Element for this guide.

---

From your loomio group, add a Matrix Chatbot
![loomio matrix bot menu](loomio-add-matrix-bot.png)

Here's the form to complete
![loomio matrix bot form](loomio-matrix-bot-form.png)

Here's where you start to find your access token
![matrix settings menu](matrix-settings-menu.png)

Here's the settings page
![matrix settings](matrix-settings.png)

Here's the access token itself
![matrix access token](matrix-access-token.png)

Now you need the room id..
![matrix room settings](matrix-room-settings.png)

Here it is.
![matrix room id](matrix-room-id.png)
