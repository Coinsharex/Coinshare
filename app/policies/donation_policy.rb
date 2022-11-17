# frozen_string_literal: true

module Coinbase
  # Policy to determine donation-access by account
  class DonationPolicy
    def initialize(account, donation)
      @account = account
      @donation = donation
    end

    # CAN CHANGE IN NEXT MILESTONE
    def can_view?
      true
    end

    def can_edit?
      account_is_donor?
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?
      }
    end

    private

    def account_is_donor?
      @donation.donor == @account
    end
  end
end
