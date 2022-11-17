# frozen_string_literal: true

module Coinbase
  # Maps Google account details to attributes
  class GoogleAccount
    def initialize(g_account)
      @g_account = g_account
    end

    def first_name
      @g_account['given_name']
    end

    def last_name
      @g_account['family_name']
    end

    def email
      @g_account['email']
    end

    def picture
      @g_account['picture']
    end
  end
end
