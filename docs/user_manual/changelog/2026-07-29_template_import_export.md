# Share templates with JSON

Discussion and poll templates can now be shared between groups, organizations, and Loomio instances as JSON files. The files can also be stored in Git to keep a versioned history of template changes.

Use **Export json** in a template's action menu to download it. The filename includes the source group's full name so exported templates are easier to identify.

To use a shared template, select **New template**, then **Import json**. Importing populates the new-template form so the content and settings can be reviewed and edited before the template is saved.

Anyone who can access a group's templates can export them. Group admins can import templates, as can group members when **Members can create templates** is enabled.

Template files contain template content and settings, but not record IDs, authorship, timestamps, attachments, or other ownership metadata. Links from discussion templates to custom poll templates are not included because those links use instance-specific record IDs; export and import the poll templates separately.
