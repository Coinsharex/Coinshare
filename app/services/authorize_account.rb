# frozen_string_literal: true

module Coinbase
  # Authorize an account
  class AuthorizeAccount
    # Error if requesting to see forbidden account
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that account'
      end
    end

    def self.call(auth:, email:, auth_scope:)
      account = Account.first(email:)
      policy = AccountPolicy.new(auth[:account], account)
      policy.can_view? ? account : raise(ForbiddenError)

      raise ForbiddenError unless policy.can_view?

      account_and_token(account, auth_scope)
    end

    def self.account_and_token(account, auth_scope)
      {
        type: 'authorized_account',
        attributes: {
          account:,
          auth_token: AuthToken.create(account, auth_scope)
        }
      }
    end
  end
end
