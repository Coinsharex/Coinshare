# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Authentication Routes' do
  include Rack::Test::Methods

  before do
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    wipe_database
  end

  describe 'Account Authentication' do
    before do
      @account_data = DATA[:accounts][1]
      @account = Coinbase::Account.create(@account_data)
    end

    it 'HAPPY: should authenticate valid credentials' do
      credentials = { email: @account_data['email'],
                      password: @account_data['password'] }
      post 'api/v1/auth/authenticate', credentials.to_json, @req_header

      auth_account = JSON.parse(last_response.body)['attributes']
      _(last_response.status).must_equal 200
      _(auth_account['first_name']).must_equal(@account_data['first_name'])
      _(auth_account['last_name']).must_equal(@account_data['last_name'])
      _(auth_account['email']).must_equal(@account_data['email'])
      _(auth_account['occupation']).must_equal(@account_data['occupation'])
      _(auth_account['university']).must_equal(@account_data['university'])
      _(auth_account['field_of_study']).must_equal(@account_data['field_of_study'])
      _(auth_account['study_level']).must_equal(@account_data['study_level'])
      _(auth_account['bio']).must_equal(@account_data['bio'])

      _(auth_account['id']).must_be_nil
    end

    it 'BAD: should not authenticate invalid password' do
      credentials = { email: @account_data['email'],
                      password: 'fakepassword' }

      post 'api/v1/auth/authenticate', credentials.to_json, @req_header
      result = JSON.parse(last_response.body)

      _(last_response.status).must_equal 403
      _(result['message']).wont_be_nil
      _(result['attributes']).must_be_nil
    end
  end
end
