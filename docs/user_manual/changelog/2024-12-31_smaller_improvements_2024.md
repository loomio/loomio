# Smaller improvements (2024)

- **Blank threads now notify by default.** When you start a new thread, the default notification setting is now "Notify group members" rather than leaving the thread unannounced, reducing the chance of silent threads nobody knows about.
- **Simplified poll announce permissions.** The permission to announce a poll to the group has been streamlined. If the group allows it, any member can notify the group about a new poll. Previously this required separate checks that were easy to misconfigure.
- **Email-to-group for public groups.** Groups set to "Anyone can join" or "Anyone can see" can now receive discussion-starting emails from non-members, not just from existing group members. The email address is shown on the public group page.
- **Removed contact request.** The legacy "contact request" feature has been removed. Use the request-to-join flow for closed groups or the email-to-group feature to reach group coordinators instead.
- **WebEx support added.** Meeting polls now support WebEx alongside the existing video conferencing options.
- **Custom login logos.** Instance admins can set custom logos for Google and SAML login buttons, and apply a grayscale filter to the sidebar logo in dark mode for a cleaner look.
- **Redirect users to a group.** Instance admins can set an environment variable to redirect signed-in users to a specific group page instead of the dashboard on login.
