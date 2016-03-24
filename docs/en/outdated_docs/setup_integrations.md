# Setup Loomio integrations
File upload support.

Loomio uses an s3 bucket to store attachements and image uploads.
Create an s3 bucket and put it's name into the AWS_BUCKET config variable.
Use IAM to generate a AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY

On your bucket you will need to add a CORS policy like this:
```
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
    <CORSRule>
        <AllowedOrigin>https://*.loomio.org</AllowedOrigin>
        <AllowedMethod>POST</AllowedMethod>
        <AllowedMethod>GET</AllowedMethod>
        <MaxAgeSeconds>3000</MaxAgeSeconds>
        <AllowedHeader>*</AllowedHeader>
    </CORSRule>
</CORSConfiguration>
```

and a bucket policy like this:
```
{
	"Version": "2008-10-17",
	"Id": "Policy1418874082498",
	"Statement": [
		{
			"Sid": "Stmt1418873894189",
			"Effect": "Allow",
			"Principal": {
				"AWS": "*"
			},
			"Action": "s3:GetObject",
			"Resource": "arn:aws:s3:::loomio-attachments/*"
		}
	]
}
```
Create a bucket on aws. Get the keys and put them in the vars. Also put the correct ACL on the bucket.

Single Sign on
Facebook - From developers.facebook.com start an app, enter your hostname details and get the keys
Google - from cloud.google.com get create a thing and get the keys

Google Addressbook integration

