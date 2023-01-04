# frozen_string_literal: true

module Coinbase
  # Service Object to allow a user to update an account
  class UpdateAccount
    # Error when user cannot update account
    class ForbiddenError < StandardError
      def message
        'You are not allowed to update that account'
      end
    end

    def self.call(auth:, email:, data:)
      account = Account.first(email:)
      policy = AccountPolicy.new(auth[:account], account)

      raise ForbiddenError unless policy.can_edit?

      update_account(email, data)
      Account.first(email:)
    end

    def self.update_account(email, data)
      Account.where(email:).update(data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
