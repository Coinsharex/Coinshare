# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test loan Handling' do
  before do
    wipe_database

    DATA[:requests].each do |request_data|
      Coinbase::Request.create(request_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    loan_data = DATA[:loans][1]
    req = Coinbase::Request.first
    new_loan = req.add_loan(loan_data)

    loan = Coinbase::Loan.find(id: new_loan.id)
    _(loan.amount).must_equal loan_data['amount']
    _(loan.identifier).must_equal loan_data['identifier']
    _(loan.interest_rate).must_equal loan_data['interest_rate']
    _(loan.duration).must_equal loan_data['duration']
    _(loan.penalty_fee).must_equal loan_data['penalty_fee']
  end

  it 'SECURITY: should not use deterministic integers' do
    loan_data = DATA[:loans][1]
    req = Coinbase::Request.first
    new_loan = req.add_loan(loan_data)

    _(new_loan.id.is_a?(Numeric)).must_equal false
  end
end
