# frozen_string_literal: true

module Coinbase
  # Service object to create a new request for an account
  class CreateRequest
    # Error for account cannot add requests
    class MonthlyRequestAllowanceError < StandardError; end
    class YearlyFundsAllownaceError < StandardError; end

    def self.call(auth:, req_data:)
      policy = NewRequestPolicy.new(auth[:account], auth[:scope], req_data:)

      raise MonthlyRequestAllowanceError unless policy.can_add_requests_for_current_month?
      raise YearlyFundsAllownaceError unless policy.can_ask_more_funds?

      auth[:account].add_request(req_data)
    end
  end
end
