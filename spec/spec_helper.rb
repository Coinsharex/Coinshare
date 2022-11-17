# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  Coinbase::Donation.map(&:destroy)
  Coinbase::Request.map(&:destroy)
  Coinbase::Account.map(&:destroy)
end

def auth_header(account_data)
  auth = Coinbase::AuthenticateAccount.call(
    email: account_data['email'],
    password: account_data['password']
  )

  "Bearer #{auth[:attributes][:auth_token]}"
end

DATA = {
  accounts: YAML.safe_load(File.read('app/db/seeds/account_seeds.yml')),
  donations: YAML.safe_load(File.read('app/db/seeds/donation_seeds.yml')),
  requests: YAML.safe_load(File.read('app/db/seeds/request_seeds.yml'))
}.freeze
