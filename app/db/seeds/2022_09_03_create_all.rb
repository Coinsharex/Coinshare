# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding account, requests and donations'
    create_accounts
    create_requests_made
    create_donations
    add_donations_to_request
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
REQUESTOR_INFO = YAML.load_file("#{DIR}/requestors.yml")
REQUEST_INFO = YAML.load_file("#{DIR}/request_seeds.yml")
DONATION_INFO = YAML.load_file("#{DIR}/donation_seeds.yml")
DONATION_SUBMITTER_INFO = YAML.load_file("#{DIR}/submitters_donations.yml")
REQUEST_DONATIONS = YAML.load_file("#{DIR}/requests_donations.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    Coinbase::Account.create(account_info)
  end
end

def create_requests_made
  REQUESTOR_INFO.each do |requestor|
    account = Coinbase::Account.first(email: requestor['email'])
    requestor['req_title'].each do |request|
      req_data = REQUEST_INFO.find { |req| req['title'] == request }
      Coinbase::CreateRequest.call(
        owner_id: account.id, req_data:
      )
    end
  end
end

def create_donations
  DONATION_SUBMITTER_INFO.each do |donator|
    account = Coinbase::Account.first(email: donator['email'])
    donator['don_identifier'].each do |donation|
      donation_data = DONATION_INFO.find { |don| don['identifier'] == donation }
      Coinbase::CreateDonation.call(
        submitter_id: account.id, donation_data:
      )
    end
  end
end

def add_donations_to_request
  REQUEST_DONATIONS.each do |req_don|
    req = Coinbase::Request.first(title: req_don['title'])
    donation = Coinbase::Donation.first(identifier: req['identifier'])
    Coinbase::AddDonationToRequest.call(
      request_id: req.id, donation_id: donation.id
    )
  end
end
