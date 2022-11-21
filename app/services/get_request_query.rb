# frozen_string_literal: true

module Coinbase
  # Request details
  class GetRequestQuery
    # Error for account does not have access to request
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that request'
      end
    end

    # Error for cannot find request
    class NotFoundError < StandardError
      def message
        'We could not find that request'
      end
    end

    def self.call(auth:, request:)
      raise NotFoundError unless request

      policy = RequestPolicy.new(auth[:account], request, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      request.full_details.merge(policies: policy.summary)
    end
  end
end
