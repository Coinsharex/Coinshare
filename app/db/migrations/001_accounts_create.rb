# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts) do
      primary_key :id

      String    :first_name, null: false
      String    :last_name, null: false
      String    :email, unique: true, null: false
      String    :password_digest
      String    :occupation, null: false
      String    :university
      String    :field_of_study
      String    :study_level
      File      :picture
      String    :bio

      DateTime  :created_at
      DateTime  :updated_at
    end
  end
end
