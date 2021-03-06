# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

feature 'Participant Phone Number' do
  let(:existing_phone_number) { PhoneNumber.new(id: '1', number: '9175555555', type: 'Work') }
  let(:marge) { FactoryGirl.create(:participant, phone_numbers: [existing_phone_number]) }
  let(:screening) { FactoryGirl.create(:screening, participants: [marge]) }

  before do
    stub_request(:get, intake_api_url(ExternalRoutes.intake_api_screening_path(screening.id)))
      .and_return(json_body(screening.to_json, status: 200))
    stub_request(
      :put, intake_api_url(ExternalRoutes.intake_api_participant_path(marge.id))
    ).and_return(json_body(marge.to_json, status: 200))
    stub_empty_relationships_for_screening(screening)
    stub_empty_history_for_screening(screening)
  end

  scenario 'adding a new phone number to a participant' do
    visit edit_screening_path(id: screening.id)

    marge.phone_numbers << PhoneNumber.new(number: '7894561245', type: 'Home')

    within edit_participant_card_selector(marge.id) do
      click_button 'Add new phone number'
      within all('.list-item').last do
        fill_in 'Phone Number', with: '7894561245'
        select 'Home', from: 'Phone Number Type'
      end

      click_button 'Save'
    end

    expect(a_request(:put, intake_api_url(ExternalRoutes.intake_api_participant_path(marge.id)))
      .with(body: hash_including(
        'phone_numbers' => array_including(
          hash_including('number' => '9175555555', 'type' => 'Work'),
          hash_including('number' => '(789)456-1245', 'type' => 'Home')
        )
      ))).to have_been_made
  end

  scenario 'editing a phone number from a participant' do
    visit edit_screening_path(id: screening.id)

    marge.phone_numbers.first.number = '7894561245'

    within edit_participant_card_selector(marge.id) do
      expect(page).to have_field('Phone Number', with: '(917)555-5555')
      expect(page).to have_field('Phone Number Type', with: 'Work')
      fill_in 'Phone Number', with: '7894561245'

      click_button 'Save'
    end

    expect(a_request(:put, intake_api_url(ExternalRoutes.intake_api_participant_path(marge.id)))
      .with(body: hash_including(
        'phone_numbers' => array_including(
          hash_including('number' => '(789)456-1245', 'type' => existing_phone_number.type)
        )
      ))).to have_been_made
  end

  scenario 'deleting an existing phone number from a participant' do
    visit screening_path(id: screening.id)

    within show_participant_card_selector(marge.id) do
      expect(page).to have_content('(917)555-5555')

      click_link 'Edit person'
    end

    marge.phone_numbers = []

    within edit_participant_card_selector(marge.id) do
      click_link 'Delete phone number'
      expect(page).to_not have_content('(917)555-5555')

      click_button 'Save'
    end

    expect(a_request(:put, intake_api_url(ExternalRoutes.intake_api_participant_path(marge.id)))
      .with(body: hash_including('phone_numbers' => []))).to have_been_made
  end

  scenario 'filling phone number with a combinaiton of valid and invalid characters' do
    visit edit_screening_path(id: screening.id)

    within edit_participant_card_selector(marge.id) do
      within '.card-body' do
        fill_in 'Phone Number', with: 'as(343ld81103kjs809u38'
        expect(page).to have_field('Phone Number', with: '(343)811-0380')
      end
      click_button 'Save'

      marge.phone_numbers.first.number = '3438110380'
      expect(a_request(:put, intake_api_url(ExternalRoutes.intake_api_participant_path(marge.id)))
        .with(body: hash_including(
          'phone_numbers' => array_including(
            hash_including('number' => '(343)811-0380', 'type' => existing_phone_number.type)
          )
        ))).to have_been_made
    end
  end
end
