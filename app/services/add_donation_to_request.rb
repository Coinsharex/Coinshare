# frozen_string_literal: true

module Coinbase
  # Add a donation to a request
  class AddDonationToRequest
    # Error for requestor cannot be donor
    class RequestorNotDonor < StandardError
      def message = 'Requestor cannot be donor'
    end

    def self.call(req_id:, donation_id:)
      request = Request.first(id: req_id)
      donation = Donation.first(id: donation_id)
      raise(RequestorNotDonor) if request.requestor == donation.donor

      request.add_donation(donation)
    end
  end
end
