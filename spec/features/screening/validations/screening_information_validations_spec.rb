# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'
require 'support/factory_girl'

feature 'Screening Information Validations' do
  let(:screening) { FactoryGirl.create(:screening) }

  context 'On the edit page' do
    before do
      stub_and_visit_edit_screening(screening)
    end

    context 'social worker field' do
      let(:error_message) { 'Please enter an assigned worker.' }

      scenario 'displays errors if a user does not enter a social worker' do
        within '#screening-information-card.edit' do
          expect(page).not_to have_content(error_message)
          fill_in 'Assigned Social Worker', with: ''
          expect(page).not_to have_content(error_message)
          blur_field
          expect(page).to have_content(error_message)
          fill_in 'Assigned Social Worker', with: 'My Name'
          expect(page).not_to have_content(error_message)
        end
      end

      scenario 'show card displays errors until user adds a social worker' do
        validate_message_as_user_interacts_with_card(
          invalid_screening: screening,
          card_name: 'screening-information',
          error_message: error_message,
          screening_updates: { assignee: 'My Name' }
        ) do
          within '#screening-information-card.edit' do
            fill_in 'Assigned Social Worker', with: 'My Name'
          end
        end
      end
    end

    context 'communication method field' do
      let(:error_message) { 'Please select a communication method.' }

      scenario 'displays errors if a user does not enter a communication method' do
        within '#screening-information-card.edit' do
          expect(page).not_to have_content(error_message)
          select '', from: 'Communication Method'
          expect(page).not_to have_content(error_message)
          blur_field
          expect(page).to have_content(error_message)
          select 'Email', from: 'Communication Method'
          expect(page).not_to have_content(error_message)
        end
      end

      scenario 'show card displays errors until user adds a communication method' do
        validate_message_as_user_interacts_with_card(
          invalid_screening: screening,
          card_name: 'screening-information',
          error_message: error_message,
          screening_updates: { communication_method: 'email' }
        ) do
          within '#screening-information-card.edit' do
            select 'Email', from: 'Communication Method'
          end
        end
      end
    end

    context 'end date field' do
      let(:error_message) { 'The end date and time cannot be in the future.' }

      scenario 'displays an error if the date is in the future' do
        validate_message_as_user_interacts_with_date_field(
          card_name: 'screening-information',
          field: 'Screening End Date/Time',
          error_message: error_message,
          invalid_value: 20.years.from_now,
          valid_value: 20.years.ago
        )
      end

      context 'with a screening saved with end date in the future' do
        let(:screening) do
          FactoryGirl.create(:screening, ended_at: 30.years.from_now)
        end
        let(:valid_date) { 20.years.ago.iso8601 }

        scenario 'show card shows errors until the date is not in the future' do
          validate_message_as_user_interacts_with_card(
            invalid_screening: screening,
            card_name: 'screening-information',
            error_message: error_message,
            screening_updates: { ended_at: valid_date }
          ) do
            select_today_from_calendar '#ended_at'
          end
        end
      end
    end

    context 'start date field' do
      scenario 'displays an error if the user does not enter a start date' do
        validate_message_as_user_interacts_with_date_field(
          card_name: 'screening-information',
          field: 'Screening Start Date/Time',
          error_message: 'Please enter a screening start date.',
          invalid_value: '',
          valid_value: 20.years.ago
        )
      end

      scenario 'displays an error if the user enters a start date in the future' do
        validate_message_as_user_interacts_with_date_field(
          card_name: 'screening-information',
          field: 'Screening Start Date/Time',
          error_message: 'The start date and time cannot be in the future.',
          invalid_value: 20.years.from_now,
          valid_value: 20.years.ago
        )
      end

      scenario 'show card displays errors until user enters a start date' do
        validate_message_as_user_interacts_with_card(
          invalid_screening: screening,
          card_name: 'screening-information',
          error_message: 'Please enter a screening start date.',
          screening_updates: { started_at: '08/17/2016 3:00 AM' }
        ) { select_today_from_calendar '#started_at' }
      end

      context 'with a screening that also has an end date' do
        let(:screening) { FactoryGirl.create :screening, ended_at: 10.years.ago }

        scenario 'displays an error if the user enters a start date that is after the end date' do
          validate_message_as_user_interacts_with_date_field(
            card_name: 'screening-information',
            field: 'Screening Start Date/Time',
            error_message: 'The start date and time must be before the end date and time.',
            invalid_value: 5.years.ago,
            valid_value: 15.years.ago
          )
        end
      end

      context 'with a screening saved with start date in the future' do
        let(:screening) do
          FactoryGirl.create(:screening, started_at: 20.years.from_now)
        end

        scenario 'show card shows errors until the date is not in the future' do
          validate_message_as_user_interacts_with_card(
            invalid_screening: screening,
            card_name: 'screening-information',
            error_message: 'The start date and time cannot be in the future.',
            screening_updates: { started_at: 20.years.ago }
          ) { select_today_from_calendar '#started_at' }
        end
      end

      context 'With a screening saved with start dates after the end date' do
        let(:screening) do
          FactoryGirl.create(:screening, started_at: 10.years.ago, ended_at: 20.years.ago)
        end

        scenario 'show card shows errors until the start date is before the end date' do
          valid_date = 30.years.ago
          validate_message_as_user_interacts_with_card(
            invalid_screening: screening,
            card_name: 'screening-information',
            error_message: 'The start date and time must be before the end date and time.',
            screening_updates: { started_at: valid_date.iso8601 }
          ) do
            within '#screening-information-card.edit' do
              fill_in_datepicker 'Screening Start Date/Time', with: valid_date
            end
          end
        end
      end
    end
  end

  context 'On the show page' do
    let(:show_card) { '#screening-information-card.show' }
    before do
      stub_request(:get, intake_api_url(ExternalRoutes.intake_api_screening_path(screening.id)))
        .and_return(json_body(screening.to_json, status: 200))
      stub_empty_relationships_for_screening(screening)
      stub_empty_history_for_screening(screening)

      visit screening_path(id: screening.id)
    end

    scenario 'user sees error messages for required fields page load' do
      should_have_content 'Please enter an assigned worker.', inside: show_card
      should_have_content 'Please select a communication method.', inside: show_card
      should_have_content 'Please enter a screening start date.', inside: show_card
    end

    context 'for a screening that has a saved dates in the future' do
      let(:screening) do
        FactoryGirl.create :screening, started_at: 5.years.from_now, ended_at: 10.years.from_now
      end

      scenario 'user sees error messages for dates being in the future on page load' do
        should_have_content 'The start date and time cannot be in the future.', inside: show_card
        should_have_content 'The end date and time cannot be in the future.', inside: show_card
      end
    end

    context 'for a screening saved with the start date after the end date' do
      let(:screening) do
        FactoryGirl.create :screening, started_at: 5.years.ago, ended_at: 10.years.ago
      end

      scenario 'user sees error messages for start date being after end date page load' do
        should_have_content(
          'The start date and time must be before the end date and time.',
          inside: show_card
        )
      end
    end
  end
end
