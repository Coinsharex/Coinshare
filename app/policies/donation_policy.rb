# frozen_string_literal: true

module Coinbase
  # Policy to determine donation-access by account
  class DonationPolicy
    def initialize(account, donation, auth_scope = nil)
      @account = account
      @donation = donation
      @auth_scope = auth_scope
    end

    # CAN CHANGE IN NEXT MILESTONE
    def can_view?
      true
    end

    def can_edit?
      can_write? && account_is_donor?
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

    def can_write?
      @auth_scope ? @auth_scope.can_write?('donations') : false
    end
  end
end
