# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Account Handling' do
  include Rack::Test::Methods

  before do
    header 'CONTENT_TYPE', 'application/json'
    wipe_database
  end

  describe 'Account information' do
    it 'HAPPY: should be able to get details of a single account' do
      account_data = DATA[:accounts][1]
      account = Coinbase::Account.create(account_data)

      header 'AUTHORIZATION', auth_header(account_data)
      get "/api/v1/accounts/#{account.email}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['attributes']

      _(result['first_name']).must_equal account.first_name
      _(result['last_name']).must_equal account.last_name
      _(result['email']).must_equal account.email
      _(result['occupation']).must_equal account.occupation
      _(result['university']).must_equal account.university
      _(result['field_of_study']).must_equal account.field_of_study
      _(result['study_level']).must_equal account.study_level
      _(result['salt']).must_be_nil
      _(result['password']).must_be_nil
      _(result['password_hash']).must_be_nil
    end
  end

  describe 'Account Creation' do
    before do
      @account_data = DATA[:accounts][1]
    end

    it 'HAPPY: should be able to create new accounts' do
      post 'api/v1/accounts', @account_data.to_json
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      account = Coinbase::Account.first

      _(created['email']).must_equal @account_data['email']
      _(created['first_name']).must_equal @account_data['first_name']
      _(created['last_name']).must_equal @account_data['last_name']
      _(created['email']).must_equal @account_data['email']
      _(created['occupation']).must_equal @account_data['occupation']
      _(created['university']).must_equal @account_data['university']
      _(created['field_of_study']).must_equal @account_data['field_of_study']
      _(created['study_level']).must_equal @account_data['study_level']
      _(account.password?(@account_data['password'])).must_equal true
      _(account.password?('not_really_the_password')).must_equal false
    end

    it 'BAD: should not create account with illegal attributes' do
      bad_data = @account_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/accounts', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
