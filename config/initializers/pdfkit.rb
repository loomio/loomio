PDFKit.configure do |config| 
  
#  config.wkhtmltopdf = '/usr/local/Cellar/wkhtmltopdf/0.11.0_rc1/bin/wkhtmltopdf' #Path to your wkhtmltppdf installation directory      
  config.default_options = { page_size: 'A4', print_media_type: true }
  
#  config.root_url = "http://localhost" # Use only if your external hostname is unavailable on the server.
end