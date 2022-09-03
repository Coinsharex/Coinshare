# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test donation Handling' do
  before do
    wipe_database

    DATA[:requests].each do |request_data|
      Coinbase::Request.create(request_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    donation_data = DATA[:donations][1]
    req = Coinbase::Request.first
    new_donation = req.add_donation(donation_data)

    donation = Coinbase::Donation.find(id: new_donation.id)
    _(donation.amount).must_equal donation_data['amount']
    _(donation.identifier).must_equal donation_data['identifier']
  end

  it 'SECURITY: should not use deterministic integers' do
    donation_data = DATA[:donations][1]
    req = Coinbase::Request.first
    new_donation = req.add_donation(donation_data)

    _(new_donation.id.is_a?(Numeric)).must_equal false
  end
end
