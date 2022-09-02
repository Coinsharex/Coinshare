# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Request Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all requests' do
    Coinbase::Request.create(DATA[:requests][0]).save
    Coinbase::Request.create(DATA[:requests][1]).save

    get 'api/v1/requests'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single request' do
    existing_req = DATA[:requests][1]
    Coinbase::Request.create(existing_req).save
    id = Coinbase::Request.first.id

    get "api/v1/requests/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['reason']).must_equal existing_req['reason']
    _(result['data']['attributes']['amount']).must_equal existing_req['amount']
  end

  it 'SAD: should return error if unknown request requested' do
    get '/api/v1/requests/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new requests' do
    existing_req = DATA[:requests][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/requests', existing_req.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    req = Coinbase::Request.first

    _(created['id']).must_equal req.id
    _(created['reason']).must_equal existing_req['reason']
    _(created['identifier']).must_equal existing_req['identifier']
  end
end
