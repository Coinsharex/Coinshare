# frozen_string_literal: true

module Coinbase
  # Request details
  class GetRequestQuery
    # Error for cannot find request
    class NotFoundError < StandardError
      def message
        'We could not find that request'
      end
    end

    def self.call(account:, request:)
      raise NotFoundError unless request

      policy = RequestPolicy.new(account, request)

      request.full_details.merge(policies: policy.summary)
    end
  end
end
