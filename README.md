Skeleton is an ongoing project to document and compare cloud hosting
solutions for an app in [Node](https://nodejs.org).

Skeleton features:

* local testability (where possible)
* a static file content handler
* a generated content handler
* Makefile to fetch depdendencies, test locally, deploy, and test remotely

The supported cloud solutions include:

* AWS Lambda
* Amazon EC2 Container Service
* Digital Ocean Droplet (on Debian)
* Google Cloud Functions
* Google Container Engine
* Heroku Dynos

Useful `make` targets:

* run
* test
* run_local
* deploy
* revoke
* clean
