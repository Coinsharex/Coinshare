# frozen_string_literal: true

module Coinbase
  # Service object to create a new request for an account
  class CreateRequest
    def self.call(requestor:, req_data:)
      Account.find(id: requestor)
             .add_request(req_data)
    end
  end
end
