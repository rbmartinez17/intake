# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

feature 'Edit Screening' do
  scenario 'edit an existing screening' do
    existing_screening = {
      id: 1,
      ended_at: '2016-08-13T11:00:00.000Z',
      incident_county: 'sacramento',
      incident_date: '2016-08-11',
      communication_method: 'phone',
      name: 'Little Shop Of Horrors',
      report_narrative: 'Narrative 123 test',
      reference: 'My Bad!',
      response_time: 'immediate',
      screening_decision: 'evaluate_out',
      started_at: '2016-08-13T10:00:00.000Z',
      address: {
      },
      participants: [
        { id: 1, first_name: 'Homer', last_name: 'Simpson' }
      ]
    }.with_indifferent_access

    faraday_stub = Faraday.new do |builder|
      builder.adapter :test do |stub|
        stub.get('/api/v1/screenings/1') do |_|
          [200, {}, existing_screening]
        end
      end
    end
    allow(API).to receive(:connection).and_return(faraday_stub)

    visit edit_screening_path(id: existing_screening[:id])
    expect(page).to have_content 'Edit Screening #My Bad!'

    within '#screening-information-card' do
      expect(page).to have_field('Title/Name of Screening', with: 'Little Shop Of Horrors')
      expect(page).to have_field('Screening Start Date/Time', with: '2016-08-13 10:00:00 UTC')
      expect(page).to have_field('Screening End Date/Time', with: '2016-08-13 11:00:00 UTC')
      expect(page).to have_field('Communication Method', with: 'phone')
    end

    within '#participants-card' do
      expect(page).to have_content 'Homer Simpson'
    end

    within '#narrative-card' do
      expect(page).to have_field('Report Narrative', with: 'Narrative 123 test')
    end

    within '#referral-information-card' do
      expect(page).to have_field('Incident Date', with: '2016-08-11')
      expect(page).to have_field('Incident County', with: 'sacramento')
      expect(page).to have_field('Response Time', with: 'immediate')
      expect(page).to have_field('Screening Decision', with: 'evaluate_out')
    end

    search_results = [Participant.new(first_name: 'Marge', last_name: 'Simpson')]
    allow(PeopleRepo).to receive(:search)
      .with('Marge')
      .and_return(search_results)

    within '#screening-information-card' do
      fill_in 'Title/Name of Screening', with: 'The Rocky Horror Picture Show'
      fill_in 'Screening Start Date/Time', with: '2016-08-13 10:00 AM'
      fill_in 'Screening End Date/Time', with: '2016-08-22 11:00 AM'
      select  'Mail', from: 'Communication Method'
    end

    within '#participants-card' do
      fill_in_autocompleter 'Participants', with: 'Marge'
    end

    within '#narrative-card' do
      fill_in 'Report Narrative', with: 'Updated narrative'
    end

    within '#referral-information-card' do
      fill_in 'Incident Date', with: '2016-08-11'
      select  'Mariposa', from: 'Incident County'
      within 'fieldset', text: 'Incident Address' do
        fill_in 'Address', with: '123 fake st'
        fill_in 'City', with: 'Springfield'
        select 'New York', from: 'State'
        fill_in 'Zip', with: '12345'
      end
      select "Child's Home", from: 'Location Type'
    end

    updated_screening = {
      id: 1,
      reference: 'Horror',
      name: 'The Rocky Horror Picture Show',
      report_narrative: 'Updated narrative',
      communication_method: 'mail',
      participants: [
        { id: 1, first_name: 'Homer', last_name: 'Simpson' },
        { id: 2, first_name: 'Marge', last_name: 'Simpson' }
      ],
      address: {
      }
    }.with_indifferent_access

    faraday_stub = Faraday.new do |builder|
      builder.adapter :test do |stub|
        stub.put('/api/v1/screenings/1') do |_env|
          [200, {}, updated_screening]
        end
        stub.get('/api/v1/screenings/1') do |_env|
          [200, {}, updated_screening]
        end
      end
    end
    allow(API).to receive(:connection).and_return(faraday_stub)

    click_button 'Save'

    expect(page).to_not have_content 'Edit Screening'
    expect(page).to have_content 'Screening #Horror'
  end
end