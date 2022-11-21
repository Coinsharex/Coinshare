# frozen_string_literal: true

module Coinbase
  # Service object to create a donation for an account
  class CreateDonation
    # Error for account cannot add donations
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add donations'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a donation with those attributes'
      end
    end

    def self.call(auth:, request:, donation_data:)
      policy = RequestPolicy.new(auth[:account], request, auth[:scope])
      raise ForbiddenError unless policy.can_add_donations?

      auth[:account].add_donation(donation_data)
      request.add_donation(donation_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
