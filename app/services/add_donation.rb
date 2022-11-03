# frozen_string_literal: true

module Coinbase
  # Add a donation to a request
  class AddDonation
    # Error for requestor cannot be donor
    class ForbiddenError < StandardError
      def message
        'You are not allowed to donate to your own campaign'
      end
    end

    def self.call(account:, request:, donation:)
      # request = Request.first(id: request_id)
      # donation = Donation.first(id: donation_id)
      policy = RequestPolicy.new(account, request)
      raise ForbiddenError unless policy.can_add_donations?

      request.add_donation(donation)
    end
  end
end
