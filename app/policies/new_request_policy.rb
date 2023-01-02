# frozen_string_literal: true

module Coinbase
  # Policy to determine if account can add new request
  class NewRequestPolicy
    def initialize(account, req_data, auth_scope = nil)
      @account = account
      @auth_scope = auth_scope
      @req_data = req_data
      @time = Time.now
      @max_amount_per_year = 5_000
      @monthly_amount_of_req = 2
    end

    def can_add_requests_for_current_month?
      current = DateTime.new(@time.year, @time.month)
      Request.where(requestor_id: @account.id) { created_at >= current }.all.count < @monthly_amount_of_req
    end

    def can_ask_more_funds?
      current = DateTime.new(@time.year, 1)
      sum = Request.where(requestor_id: @account.id) { created_at >= current }&.sum(:amount)
      sum.nil? ? true : sum + @req_data['amount'].to_i < @max_amount_per_year
    end

    private

    def can_write?
      @auth_scope ? @auth_scope.can_write?('requests') : false
    end
  end
end
