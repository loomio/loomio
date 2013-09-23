# Be sure to restart your server when you modify this file.
Mime::Type.register_alias "application/pdf", :pdf unless Mime::Type.lookup_by_extension(:pdf)
# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone
