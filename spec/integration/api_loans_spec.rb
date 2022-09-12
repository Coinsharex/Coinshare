# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Loan Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:requests].each do |request_data|
      Coinbase::Request.create(request_data)
    end
  end

  it 'HAPPY: should be able to get list of all loans' do
    request = Coinbase::Request.first
    DATA[:loans].each do |don|
      request.add_loan(don)
    end

    get "api/v1/requests/#{request.id}/loans"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single loan' do
    loan_data = DATA[:loans][1]
    req = Coinbase::Request.first
    loan = req.add_loan(loan_data)

    get "/api/v1/requests/#{req.id}/loans/#{loan.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal loan.id
    _(result['data']['attributes']['amount']).must_equal loan_data['amount']
    _(result['data']['attributes']['identifier']).must_equal loan_data['identifier']
    _(result['data']['attributes']['interest_rate']).must_equal loan_data['interest_rate']
    _(result['data']['attributes']['duration']).must_equal loan_data['duration']
    _(result['data']['attributes']['penalty_fee']).must_equal loan_data['penalty_fee']
  end

  it 'SAD: should return error if unknown loan requested' do
    req = Coinbase::Request.first
    get "api/v1/requests/#{req.id}/loans/foobar"

    _(last_response.status).must_equal 404
  end

  describe 'Creating loans' do
    before do
      @req = Coinbase::Request.first
      @loan_data = DATA[:loans][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new loans' do
      post "api/v1/requests/#{@req.id}/loans", @loan_data.to_json, @req_header

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      loan = Coinbase::Loan.first

      _(created['id']).must_equal loan.id
      _(created['amount']).must_equal @loan_data['amount']
      _(created['identifier']).must_equal @loan_data['identifier']
      _(created['interest_rate']).must_equal @loan_data['interest_rate']
      _(created['duration']).must_equal @loan_data['duration']
      _(created['penalty_fee']).must_equal @loan_data['penalty_fee']
    end

    it 'SECURITY: should not create loans with mass assignment' do
      bad_data = @loan_data.clone
      bad_data['created_at'] = '1900-01-01'

      post "api/v1/requests/#{@req.id}/loans", bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
