# frozen_string_literal: true

module Coinbase
  # Policy to determine if an account can update an existing request
  class UpdateRequestPolicy
    def initialize(account, request, updated_data, auth_scope = nil)
      @account = account
      @request = request
      @req_data = updated_data
      @auth_scope = auth_scope
      @time = Time.now
      @max_amount_per_year = 5_000
    end

    def can_update?
      can_ask_more_funds?
    end

    private

    def can_ask_more_funds?
      current_year = Date.new(@time.year, 1)
      sum_all_requests = Request.where(requestor_id: @account.id) { created_at >= current_year }&.sum(:amount)
      req_new_amount = sum_all_requests - @request.amount + @req_data['amount'].to_i
      req_new_amount < @max_amount_per_year
    end
  end
end
