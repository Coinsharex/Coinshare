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

      donation = auth[:account].add_donation(donation_data)
      request.add_donation(donation)
      # Create or update a summary for request
      create_or_update_summary(request, donation_data['amount'])
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end

    def self.create_or_update_summary(request, price)
      if RequestDonationsDetails.where(request_id: request.id).empty?
        request.summary = RequestDonationsDetails.create(count: 1, amount: price)
      else
        donation_details = RequestDonationsDetails.where(request_id: request.id).first
        donation_details.count += 1
        donation_details.amount += price
        donation_details.save
      end
    end
  end
end
