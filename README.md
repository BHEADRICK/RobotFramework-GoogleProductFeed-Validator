# RobotFramework-GoogleProductFeed-Validator
RobotFramework test to validate google product feed


This is designed to follow the feed spec here:
https://support.google.com/merchants/answer/7052112?hl=en

It is intended to pinpoint issues that may get a product disapproved since Google Merchant isn't always clear on where the issue lies

to run the test: 
robot -d results  --variable  URLS:https://example.com/feed1.xml,https://example.com/feed2.xml  Tests