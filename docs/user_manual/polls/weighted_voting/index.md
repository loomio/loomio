# Weighted voting

Weighted voting lets you give different people different amounts of influence in a poll's result. For example:

- A housing community gives each property one vote. If a member represents three properties, their choice contributes three times as much to the score as a member representing one property.
- A team invites everyone to share their view, but gives formal voting weight only to designated voters. Others can vote with weight `0`, so their choices are recorded without adding to the score. The team can use different weights for a particular poll.
- A condominium assigns voting power according to ownership share. A person with a 2.33% share can be assigned a weight of `2.33`, while someone with a 0.5% share can be assigned `0.5`.

Vote weights can have up to three decimal places, from `0` to `1,000,000`. Loomio does not track which properties a person represents, who is authorized to vote for a property, or turnout by property. Check that a poll's voting method matches any rules about how many candidates a person may select; assigning weights alone does not define those rules.

## Allow vote weights in a group

A group admin can open **Group settings → Permissions** and select **Allow vote weights**. The setting is off by default. It lets group admins set default weights for members and lets poll coordinators enable weights in new polls in that group. Polls that already use weights keep using them if the group setting is turned off later. Direct polls have no group setting; their coordinators can enable vote weights in each poll.

Vote weights are available for identified polls other than time polls and STV elections. Anonymous polls do not support them.

## Set member weights

Open the group's **Members** page. Group admins can see each member's weight and select **Edit vote weights** to edit the weights shown in the list. Select **Load more** to bring more members into the form, then select **Save vote weights**. To give every current member the same weight, enter a value under **Weight for all** and select **Set all weights**. This also changes members who are not loaded in the list. Admins can also edit one member's weight from that member's menu.

A member's weight is a default for future weighted polls. Changing it does not alter weights already copied into a poll.

## Use weights in a poll

Before voting opens, a poll coordinator can select **Use vote weights** in the poll's advanced settings. In a group poll, the poll copies each group member's current weight when that person is added as a voter. Other invited people, including everyone in a direct poll, start with weight `1`. Turning vote weights off before voting opens sets every voter in that poll back to weight `1` and removes poll-specific weights. Turning weights on again copies current group membership weights; other voters start at `1`.

Select **Manage voters** on the poll to open the voter management window. From there you can invite people, search the voter list, or move between pages of voters. Poll coordinators can edit the weights in this list and save the changes together. A weight change to a vote already cast updates the poll's score.

Select **Set all** in the Voters window to update every current voter, including voters on other pages. You can set one weight for everyone or copy each voter's current group membership weight. Voters without a current group membership receive weight `1`. This also updates people who have already voted and recalculates the poll result. Direct polls offer the one weight option because they have no group memberships.

When each choice gives one point, the results table shows **Voters** for the number of people who chose each option and **Score** for the result using their assigned weights. For voting methods where a person can give more than one point, it also shows **Equal weight score**, calculated as if every voter had weight `1`. Charts and score percentages use the assigned weights. People who can view an identified poll's votes can also see voter weights. Decide whether that visibility is suitable before enabling weights.
