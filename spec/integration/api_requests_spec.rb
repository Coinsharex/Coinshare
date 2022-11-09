# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Request Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]

    @account = Coinbase::Account.create(@account_data)
    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting requests' do
    describe 'Getting list of requests' do
      before do
        @account.add_request(DATA[:requests][0])
        @account.add_request(DATA[:requests][1])
        @account.add_request(DATA[:requests][2])
      end

      it 'HAPPY: should get list for authorized accounts' do
        header 'AUTHORIZATION', auth_header(@account_data)

        get 'api/v1/requests'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 3
      end

      it 'HAPPY: should be able to get a list of requests by category' do
        header 'AUTHORIZATION', auth_header(@account_data)

        get 'api/v1/requests/categories/school'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process without authorization' do
        get 'api/v1/requests'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get details of a single request' do
      req = @account.add_request(DATA[:requests][0])

      header 'AUTHORIZATION', auth_header(@account_data)

      get "api/v1/requests/#{req.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body

      _(result['attributes']['id']).must_equal req.id
      _(result['attributes']['title']).must_equal req.title
      _(result['attributes']['description']).must_equal req.description
      _(result['attributes']['amount']).must_equal req.amount
      _(result['attributes']['location']).must_equal req.location
      _(result['attributes']['category']).must_equal req.category
    end

    it 'SAD: should return error if unknown request requested' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/requests/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      @account.add_request(DATA[:requests][0])
      @account.add_request(DATA[:requests][1])

      header 'AUTHORIZATION', auth_header(@account_data)

      get '/api/v1/requests/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creatin New Requests' do
    before do
      @req_data = DATA[:requests][1]
    end

    it 'HAPPY: should be able to create new requests' do
      header 'AUTHORIZATION', auth_header(@account_data)

      post 'api/v1/requests', @req_data.to_json
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      req = Coinbase::Request.first

      _(created['id']).must_equal req.id
      _(created['title']).must_equal @req_data['title']
      _(created['description']).must_equal @req_data['description']
      _(created['amount']).must_equal @req_data['amount']
      _(created['location']).must_equal @req_data['location']
      _(created['category']).must_equal @req_data['category']
    end

    it 'SECURITY: should not create request with mass assignment' do
      bad_data = @req_data.clone
      bad_data['created_at'] = '1900-01-01'

      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/requests', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
