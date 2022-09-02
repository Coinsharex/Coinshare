# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'

require_relative '../app/controllers/app'
require_relative '../app/models/request'

def app
  Coinbase::Api
end

DATA = YAML.safe_load File.read('app/db/seeds/request_seeds.yml')

describe 'Test Coinbase Web API' do
  include Rack::Test::Methods

  before do
    # Wipe database before each test
    Dir.glob("#{Coinbase::STORE_DIR}/*.txt").each { |filename| FileUtils.rm(filename) }
  end

  it 'should find the root route' do
    get '/'
    _(last_response.status).must_equal 200
  end

  describe 'Handle requests' do
    it 'HAPPY: should be able to get list of all requests' do
      Coinbase::Request.new(DATA[0]).save
      Coinbase::Request.new(DATA[1]).save

      get 'api/v1/requests'
      result = JSON.parse last_response.body
      _(result['request_ids'].count).must_equal 2
    end

    it 'HAPPY: shoudl be able to get details of a single request' do
      Coinbase::Request.new(DATA[1]).save
      id = Dir.glob("#{Coinbase::STORE_DIR}/*.txt").first.split(%r{[/.]})[3]

      get "/api/v1/requests/#{id}"
      result = JSON.parse last_response.body

      _(last_response.status).must_equal 200
      _(result['id']).must_equal id
    end

    it 'SAD: shoudl return error if unknown request requested' do
      get '/api/v1/requests/foobar'

      _(last_response.status).must_equal 404
    end

    it 'HAPPY: should be able to create new requests' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post 'api/v1/requests', DATA[1].to_json, req_header

      _(last_response.status).must_equal 201
    end
  end
end
