# Coinshare API

API to allow users to post fund requests and receive funds from others.

## Routes

All routes return JSON

- GET `/`: Root route shows if Web API is running
- GET `api/v1/accounts/[username]`: Get account details
- POST `api/v1/accounts`: Create a new account
- GET `api/v1/requests/[req_id]/donations/[donation_id]`: Get a donation
- GET `api/v1/requests/[req_id]/donations`: Get a list of donations for a request
- POST `api/v1/requests/[req_id]/donations`: Upload donation for a request
- GET `api/v1/requests/[ID]`: Get information about a request
- GET `api/v1/requests`: Get list of all requests
- POST `api/v1/requests/`: Create new request

## Install

Install this API by cloning the _relevant branch_ and installing required ems from `Gemfile.lock`:

```shell
bundle install
```

Setup development database once:

```shell
rake db:migrate
```

## Test

Setup test database once:

```shell
RACK_ENV=test rake db:migrate
```

Run the test specification script in `Rakefile`:

```shell
rake spec
```

## Develop/Debug

Add fake data to the development database to work on this project:

```shell
rake db:seed
```

## Execute

Launch the API using:

```shell
rake run:dev
```

## Release check

Before submitting pull requests, please check if specs, style, and dependency audits pass (will need to be online to update dependency database):

```shell
rake release
```
