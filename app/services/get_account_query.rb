# frozen_string_literal: true

module Coinbase
  # Get details about an account
  class GetAccountQuery
    # Error if requesting to see forbidden account
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access this account'
      end
    end

    def self.call(requestor:, email:)
      account = Account.first(email:)

      policy = AccountPolicy.new(requestor, account)
      policy.can_view? ? account : raise(ForbiddenError)
    end
  end
end
