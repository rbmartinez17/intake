# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

feature 'Screening Decision Validations' do
  let(:error_message) { 'Please enter at least one allegation to promote to referral.' }
  let(:perpetrator) { FactoryGirl.create(:participant, :perpetrator) }
  let(:victim) { FactoryGirl.create(:participant, :victim) }
  let(:screening_decision_detail) { nil }
  let(:additional_information) { nil }
  let(:screening) do
    FactoryGirl.create(
      :screening,
      participants: [perpetrator, victim],
      screening_decision_detail: screening_decision_detail,
      additional_information: additional_information,
      screening_decision: screening_decision
    )
  end

  before do
    allegation = FactoryGirl.create(
      :allegation,
      victim_id: victim.id,
      perpetrator_id: perpetrator.id,
      screening_id: screening.id
    )
    screening.allegations << allegation
  end

  context 'When page is opened in edit mode' do
    before do
      stub_and_visit_edit_screening(screening)
    end

    context 'Screening decision is set to nil on page load' do
      let(:screening_decision) { nil }

      scenario 'card displays errors until user adds a screening decision' do
        validate_message_as_user_interacts_with_card(
          invalid_screening: screening,
          card_name: 'decision',
          error_message: 'Please enter a decision',
          screening_updates: { screening_decision: 'screen_out' }
        ) do
          within '#decision-card.edit' do
            select 'Screen out', from: 'Screening decision'
          end
        end
      end

      scenario 'Selecting promote to referral decision requires allegations' do
        within '#decision-card.edit' do
          expect(page).not_to have_content(error_message)
          click_button 'Cancel'
        end

        within '#decision-card.show' do
          expect(page).not_to have_content(error_message)
          click_link 'Edit'
        end

        stub_screening_put_request_with_anything_and_return(
          screening,
          with_updated_attributes: { screening_decision: 'promote_to_referral' }
        )

        within '#decision-card.edit' do
          select 'Promote to referral', from: 'Screening decision'
          blur_field
          expect(page).to have_content(error_message)
          click_button 'Save'
        end

        within '#decision-card.show' do
          expect(page).to have_content(error_message)
        end
      end

      scenario 'Clearing promote to referral decision removes error message' do
        within '#decision-card.edit' do
          select 'Promote to referral', from: 'Screening decision'
          blur_field
          expect(page).to have_content(error_message)
          select 'Screen out', from: 'Screening decision'
          blur_field
          expect(page).not_to have_content(error_message)
        end
      end

      scenario 'Adding and removing allegations shows or hides error message' do
        within '#decision-card.edit' do
          select 'Promote to referral', from: 'Screening decision'
          blur_field
          expect(page).to have_content(error_message)
        end

        within '.card.edit', text: 'Allegations' do
          fill_in_react_select "allegations_#{victim.id}_#{perpetrator.id}", with: 'General neglect'
        end

        within '#decision-card.edit' do
          expect(page).not_to have_content(error_message)
        end

        within '.card.edit', text: 'Allegations' do
          remove_react_select_option "allegations_#{victim.id}_#{perpetrator.id}", 'General neglect'
        end

        within '#decision-card.edit' do
          expect(page).to have_content(error_message)
        end
      end
    end

    context 'Screening decision is already set to promote to referral' do
      let(:screening_decision) { 'promote_to_referral' }

      scenario 'Error message does not display until user has interacted with the field' do
        within '#decision-card.edit' do
          expect(page).not_to have_content(error_message)
          select 'Promote to referral', from: 'Screening decision'
          blur_field
          expect(page).to have_content(error_message)
        end
      end

      scenario 'card displays errors until user selects a response time' do
        validate_message_as_user_interacts_with_card(
          invalid_screening: screening,
          card_name: 'decision',
          error_message: 'Please enter a response time',
          screening_updates: { screening_decision_detail: '3_days' }
        ) do
          within '#decision-card.edit' do
            select '3 days', from: 'Response time'
          end
        end
      end
    end

    context 'when screening decision is ScreenOut, decision detail is EvaluateOut in edit mode' do
      let(:screening_decision) { 'screen_out' }
      let(:screening_decision_detail) { 'evaluate_out' }
      let(:error_message) { 'Please enter additional information' }

      scenario 'displays no error on initial load' do
        should_not_have_content error_message, inside: '#decision-card.edit'
      end

      scenario 'card displays errors until user enters additional information' do
        validate_message_as_user_interacts_with_card(
          invalid_screening: screening,
          card_name: 'decision',
          error_message: error_message,
          screening_updates: { additional_information: 'My reason for evaluating out' }
        ) do
          within '.card', text: 'Decision' do
            fill_in 'Additional information', with: 'My reason for evaluating out'
          end
        end
      end

      scenario 'additional information is required' do
        within '.card', text: 'Decision' do
          expect(page).to have_css 'label.required', text: 'Additional information'
        end
      end
    end

    context 'Access Restrictions is set to mark as sensitive' do
      let(:error_message) { 'Please enter an access restriction reason' }
      let(:screening_decision) { nil }

      scenario 'displays no error on initial load' do
        should_not_have_content error_message, inside: '#decision-card.edit'
      end

      scenario 'displays error on blur' do
        within '#decision-card.edit' do
          select 'Mark as Sensitive', from: 'Access Restrictions'
          fill_in 'Restrictions Rationale', with: ''
        end
        blur_field
        should_have_content error_message, inside: '#decision-card.edit'
      end

      scenario 'shows error on page save' do
        within '#decision-card.edit' do
          select 'Mark as Sensitive', from: 'Access Restrictions'
          fill_in 'Restrictions Rationale', with: ''
        end
        blur_field
        should_have_content error_message, inside: '#decision-card.edit'
        stub_screening_put_request_with_anything_and_return(
          screening,
          with_updated_attributes: { access_restrictions: 'sensitive' }
        )
        save_card('decision')
        should_have_content error_message, inside: '#decision-card .card-body'
      end

      scenario 'removes error on change' do
        within '#decision-card.edit' do
          select 'Mark as Sensitive', from: 'Access Restrictions'
          fill_in 'Restrictions Rationale', with: ''
        end
        blur_field
        should_have_content error_message, inside: '#decision-card.edit'
        within '#decision-card.edit' do
          fill_in 'Restrictions Rationale', with: 'a rationale'
        end
        blur_field
        should_not_have_content error_message, inside: '#decision-card.edit'
      end

      scenario 'shows no error when there is content' do
        within '#decision-card.edit' do
          select 'Mark as Sensitive', from: 'Access Restrictions'
          fill_in 'Restrictions Rationale', with: 'a rationale'
        end
        blur_field
        should_not_have_content error_message, inside: '#decision-card.edit'
        stub_screening_put_request_with_anything_and_return(
          screening,
          with_updated_attributes: { restrictions_rationale: 'a rationale' }
        )
        save_card('decision')
        should_not_have_content error_message, inside: '#decision-card .card-body'
      end
    end

    context 'Access Restrictions is set to null' do
      let(:error_message) { 'Please enter an access restriction reason' }
      let(:screening_decision) { nil }

      scenario 'do not show error on restriction_rationale' do
        stub_request(:put, intake_api_url(ExternalRoutes.intake_api_screening_path(screening.id)))
          .and_return(json_body(screening.to_json, status: 200))
        blur_field
        should_not_have_content error_message, inside: '#decision-card.edit'
        save_card('decision')
        should_not_have_content error_message, inside: '#decision-card .card-body'
      end
    end
  end

  context 'When page is opened in show view' do
    before do
      stub_and_visit_show_screening(screening)
    end

    context 'Screening decision is set to nil on page load' do
      let(:screening_decision) { nil }

      scenario 'User does not see error messages on page load' do
        within '#decision-card.show' do
          expect(page).not_to have_content(error_message)
        end
      end
    end

    context 'Screening decision is already set to promote to referral' do
      let(:screening_decision) { 'promote_to_referral' }

      scenario 'User sees error messages on page load' do
        within '#decision-card.show' do
          expect(page).to have_content(error_message)
        end
      end

      scenario 'Adding and removing allegations shows or hides error message' do
        within '#decision-card.show' do
          expect(page).to have_content(error_message)
        end

        within '.card.show', text: 'Allegations' do
          click_link 'Edit'
        end

        within '.card.edit', text: 'Allegations' do
          fill_in_react_select "allegations_#{victim.id}_#{perpetrator.id}", with: 'General neglect'
        end

        within '#decision-card.show' do
          expect(page).not_to have_content(error_message)
        end

        within '.card.edit', text: 'Allegations' do
          remove_react_select_option "allegations_#{victim.id}_#{perpetrator.id}", 'General neglect'
        end

        within '#decision-card.show' do
          expect(page).to have_content(error_message)
        end
      end
    end

    context 'when screening decision is ScreenOut, decision detail is EvaluateOut in show mode' do
      let(:screening_decision) { 'screen_out' }
      let(:screening_decision_detail) { 'evaluate_out' }
      let(:error_message) { 'Please enter additional information' }

      context 'displays no error' do
        let(:additional_information) { 'not null' }
        scenario 'when additional information is not null' do
          should_not_have_content error_message, inside: '#decision-card.show'
        end
      end

      context 'displays error' do
        scenario 'when additional information is null' do
          should_have_content error_message, inside: '#decision-card.show'
        end
      end
    end
  end
end
