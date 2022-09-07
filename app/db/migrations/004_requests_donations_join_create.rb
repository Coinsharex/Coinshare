# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(request_id: :requests, loan_id: :loans)
  end
end
