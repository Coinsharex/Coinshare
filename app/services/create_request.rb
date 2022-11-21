# frozen_string_literal: true

module Coinbase
  # Service object to create a new request for an account
  class CreateRequest
    # Error for account cannot add requests
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more requests'
      end
    end

    def self.call(auth:, req_data:)
      raise ForbiddenError unless auth[:scope].can_write?('requests')

      auth[:account].add_request(req_data)
    end
  end
end
