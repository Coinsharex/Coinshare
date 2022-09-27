# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Donation Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:requests].each do |request_data|
      Coinbase::Request.create(request_data)
    end
  end

  it 'HAPPY: should be able to get list of all donations' do
    request = Coinbase::Request.first
    DATA[:donations].each do |don|
      request.add_donation(don)
    end

    get "api/v1/requests/#{request.id}/donations"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single donation' do
    donation_data = DATA[:donations][1]
    req = Coinbase::Request.first
    donation = req.add_donation(donation_data)

    get "/api/v1/requests/#{req.id}/donations/#{donation.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['attributes']['id']).must_equal donation.id
    _(result['attributes']['amount']).must_equal donation_data['amount']
    _(result['attributes']['identifier']).must_equal donation_data['identifier']
    _(result['attributes']['comment']).must_equal donation_data['comment']
  end

  it 'SAD: should return error if unknown donation requested' do
    req = Coinbase::Request.first
    get "api/v1/requests/#{req.id}/donations/foobar"

    _(last_response.status).must_equal 404
  end

  describe 'Creating donations' do
    before do
      @req = Coinbase::Request.first
      @donation_data = DATA[:donations][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new donations' do
      post "api/v1/requests/#{@req.id}/donations", @donation_data.to_json, @req_header

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      donation = Coinbase::Donation.first

      _(created['id']).must_equal donation.id
      _(created['amount']).must_equal @donation_data['amount']
      _(created['identifier']).must_equal @donation_data['identifier']
      _(created['comment']).must_equal @donation_data['comment']
    end

    it 'SECURITY: should not create donations with mass assignment' do
      bad_data = @donation_data.clone
      bad_data['created_at'] = '1900-01-01'

      post "api/v1/requests/#{@req.id}/donations", bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
