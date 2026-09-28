# Weighted voting

Weighted voting lets some votes count more than others. Each voter has a vote weight. For example:

- A housing community gives each property one vote. A member who represents three properties has a vote weight of `3`.
- A cooperative's board makes the decision, but operations staff take part in the conversation. Board members have a vote weight of `1`. Operations staff have a vote weight of `0`, so their votes are recorded but do not change the result.
- A condominium gives voting power by ownership share. Someone with a 2.33% share has a vote weight of `2.33`.

## Allow weighted voting in a group

A group admin can open **Group settings → Permissions** and select **Allow weighted voting**. Group admins can then set members' vote weights, and poll coordinators can use weighted voting in that group's polls. Direct polls do not need this setting.

![The Allow weighted voting permission in group settings](group-permission.png)

## Set members' vote weights

Open the group's **Members** page and select **Edit vote weights**. Enter vote weights and select **Save vote weights**. Vote weights can be `0` or more, with up to three decimal places. Search by name or email to find someone. To give every member the same vote weight, select **Set all vote weights**. You can also edit one member's vote weight from their menu.

![Vote weights for group members](member-weights.png)

A member's vote weight is copied into each poll they are added to. Changing it later does not change polls that already have it.

## Use weighted voting in a poll

Select **Use weighted voting** in the poll's advanced settings. You can turn it on or off after voting opens. Turning it off sets every vote weight in the poll to `1`, and any vote weights you changed for that poll are lost.

![The Use weighted voting setting in a poll](poll-setting.png)

Weighted voting works with identified polls, except time polls and STV elections.

To change one voter's vote weight, select **Manage voters**, then select the vote weight beside their name. To change everyone's, select **Set all vote weights**. You can copy each member's vote weight from the group, or give everyone the same value. Voters who are not group members get a vote weight of `1`.

![Voters in a poll with individual vote weights](poll-voter-weights.png)

## Results

Results show the plain totals and the weighted totals side by side:

- Proposals and single-choice polls show **Votes** and **Weighted votes**.
- Dot votes, score polls, and ranked choice show **Points** and **Weighted points**.

The chart shows the weighted result. Select a column heading to chart that column instead. Eligible voters and quorum count people, not vote weights. Anyone who can see the votes can see each voter's vote weight.

![A proposal result with votes and weighted votes](weighted-proposal-result.png)
