# frozen_string_literal: true

module Coinbase
  # Service object to create a donation for an account
  class CreateDonation
    def self.call(submitter_id:, donation_data:)
      Account.find(id: submitter_id)
             .add_donation(donation_data)
    end
  end
end
