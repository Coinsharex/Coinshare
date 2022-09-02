# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

module Coinbase
  STORE_DIR = 'app/db/store'

  # Holds a full secret request
  class Request
    # Create a new request by passing in hash of attributes
    def initialize(new_request)
      @id       = new_request['id'] || new_id
      @reason   = new_request['reason']
      @amount   = new_request['amount']
      @active   = new_request['active']
    end

    attr_reader :id, :reason, :amount, :active

    def to_json(options = {})
      JSON(
        {
          type: 'request',
          id:,
          reason:,
          amount:,
          active:
        },
        options
      )
    end

    # File store must be setup once when application runs
    def self.setup
      Dir.mkdir(Coinbase::STORE_DIR) unless Dir.exist? Coinbase::STORE_DIR
    end

    # Stores request in file store
    def save
      File.write("#{Coinbase::STORE_DIR}/#{id}.txt", to_json)
    end

    # Query method to find one request
    def self.find(find_id)
      request_file = File.read("#{Coinbase::STORE_DIR}/#{find_id}.txt")
      Request.new JSON.parse(request_file)
    end

    # Query method to retrieve index of all requests
    def self.all
      Dir.glob("#{Coinbase::STORE_DIR}/*.txt").map do |file|
        file.match(%r{#{Regexp.quote(Coinbase::STORE_DIR)}/(.*)\.txt})[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end
end
