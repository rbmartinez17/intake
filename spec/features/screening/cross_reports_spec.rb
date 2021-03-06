# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

feature 'cross reports' do
  let(:existing_screening) { FactoryGirl.create(:screening) }

  before do
    stub_county_agencies('c40')
    stub_county_agencies('c41')
    stub_county_agencies('c42')
  end

  scenario 'adding cross reports to an existing screening' do
    stub_request(
      :get, intake_api_url(ExternalRoutes.intake_api_screening_path(existing_screening.id))
    ).and_return(json_body(existing_screening.to_json, status: 200))
    stub_request(
      :put, intake_api_url(ExternalRoutes.intake_api_screening_path(existing_screening.id))
    ).and_return(json_body(existing_screening.to_json, status: 200))
    stub_empty_relationships_for_screening(existing_screening)
    stub_empty_history_for_screening(existing_screening)
    visit edit_screening_path(id: existing_screening.id)

    reported_on = Date.today
    communication_method = 'Electronic Report'

    within '#cross-report-card' do
      expect(page).to_not have_content 'Communication Time and Method'
      expect(page).to have_content 'County'
      select 'Sacramento', from: 'County'
      find('label', text: /\ACounty licensing\z/).click
      select 'Hoverment Agency', from: 'County licensing agency name'
      find('label', text: /\ALaw enforcement\z/).click
      select 'The Sheriff', from: 'Law enforcement agency name'
      expect(page).to have_content 'Communication Time and Method'
      fill_in_datepicker 'Cross Reported on Date', with: reported_on
      expect(find_field('Cross Reported on Date').value).to eq(reported_on.strftime('%m/%d/%Y'))
      select communication_method, from: 'Communication Method'
      click_button 'Save'
    end

    expect(
      a_request(
        :put, intake_api_url(ExternalRoutes.intake_api_screening_path(existing_screening.id))
      ).with(
        body: hash_including(
          'cross_reports' => array_including(
            hash_including(
              'county_id' => 'c42',
              'agencies' => array_including(
                hash_including('id' => 'BMG2f3J75C', 'type' => 'LAW_ENFORCEMENT'),
                hash_including('id' => 'GPumYGQ00F', 'type' => 'COUNTY_LICENSING')
              ),
              'inform_date' => reported_on.to_s(:db),
              'method' => communication_method
            )
          )
        )
      )
    ).to have_been_made
  end

  scenario 'editing cross reports to an existing screening' do
    reported_on = Date.today
    communication_method = 'Child Abuse Form'

    existing_screening.cross_reports = [
      CrossReport.new(
        county_id: 'c42',
        agencies: [
          { id: 'GPumYGQ00F', type: 'COUNTY_LICENSING' },
          { id: 'BMG2f3J75C', type: 'LAW_ENFORCEMENT' }
        ],
        method: communication_method,
        inform_date: reported_on.to_s(:db)
      )
    ]
    stub_request(
      :get, intake_api_url(ExternalRoutes.intake_api_screening_path(existing_screening.id))
    ).and_return(json_body(existing_screening.to_json, status: 200))
    stub_request(
      :put, intake_api_url(ExternalRoutes.intake_api_screening_path(existing_screening.id))
    ).and_return(json_body(existing_screening.to_json, status: 200))
    stub_empty_relationships_for_screening(existing_screening)
    stub_empty_history_for_screening(existing_screening)
    visit edit_screening_path(id: existing_screening.id)

    within '#cross-report-card' do
      expect(page).to have_select('County', selected: 'Sacramento')
      select 'San Francisco', from: 'County'
      expect(page).to have_select('County', selected: 'San Francisco')

      expect(find(:checkbox, 'County licensing')).to_not be_checked

      find('label', text: /\ALaw enforcement\z/).click
      expect(find(:checkbox, 'Law enforcement')).to be_checked

      select 'The Sheriff', from: 'Law enforcement agency name'
      find('label', text: /\ADistrict attorney\z/).click
      fill_in_datepicker 'Cross Reported on Date', with: reported_on
      expect(page).to have_field('Cross Reported on Date', with: reported_on.strftime('%m/%d/%Y'))
      select communication_method, from: 'Communication Method'
      click_button 'Save'
    end

    expect(
      a_request(
        :put, intake_api_url(ExternalRoutes.intake_api_screening_path(existing_screening.id))
      ).with(
        body: hash_including(
          'cross_reports' => array_including(
            hash_including(
              'county_id' => 'c40',
              'agencies' => array_including(
                hash_including('id' => 'BMG2f3J75C', 'type' => 'LAW_ENFORCEMENT'),
                hash_including('id' => '', 'type' => 'DISTRICT_ATTORNEY')
              ),
              'inform_date' => reported_on.to_s(:db),
              'method' => communication_method
            )
          )
        )
      )
    ).to have_been_made
  end

  scenario 'viewing cross reports on an existing screening' do
    existing_screening.cross_reports = [
      CrossReport.new(
        county_id: 'c42',
        agencies: [
          { id: 'LsUFj7O00E', type: 'COMMUNITY_CARE_LICENSING' },
          { id: 'BMG2f3J75C', type: 'LAW_ENFORCEMENT' }
        ],
        method: 'Child Abuse Form',
        inform_date: Date.today.to_s(:db)
      )
    ]
    stub_request(
      :get, intake_api_url(ExternalRoutes.intake_api_screening_path(existing_screening.id))
    ).and_return(json_body(existing_screening.to_json, status: 200))
    stub_empty_relationships_for_screening(existing_screening)
    stub_empty_history_for_screening(existing_screening)
    visit screening_path(id: existing_screening.id)

    within '#cross-report-card', text: 'Cross Report' do
      expect(page).to_not have_content 'County'
      expect(page).to_not have_content 'Sacramento'
      expect(page).to have_content 'Community care licensing'
      expect(page).to have_content "Daisie's Preschool"
      expect(page).to have_content 'Law enforcement'
      expect(page).to have_content 'The Sheriff'
      expect(page).to have_content Date.today.strftime('%m/%d/%Y')
      expect(page).to have_content 'Child Abuse Form'
    end

    click_link 'Edit cross report'

    within '#cross-report-card', text: 'Cross Report' do
      expect(page).to have_select('County', selected: 'Sacramento')
      expect(find(:checkbox, 'Law enforcement')).to be_checked
      expect(page).to have_select('Law enforcement agency name', selected: 'The Sheriff')
      expect(find(:checkbox, 'Community care licensing')).to be_checked
      expect(page).to have_select('Community care licensing agency name',
        selected: "Daisie's Preschool")
      expect(page).to have_field('Communication Method', with: 'Child Abuse Form')
      expect(page).to have_field('Cross Reported on Date', with: Date.today.strftime('%m/%d/%Y'))
    end
  end

  scenario 'viewing empty cross reports on an existing screening' do
    stub_request(
      :get,
      intake_api_url(ExternalRoutes.intake_api_screening_path(existing_screening.id))
    ).and_return(json_body(existing_screening.to_json, status: 200))
    stub_empty_relationships_for_screening(existing_screening)
    stub_empty_history_for_screening(existing_screening)
    visit screening_path(id: existing_screening.id)

    within '#cross-report-card', text: 'Cross Report' do
      expect(page).to_not have_content 'County'
      expect(page).to_not have_content 'Communication Time and Method'
      expect(page).to_not have_content 'Cross Reported on Date'
      expect(page).to_not have_content 'Communication Method'
    end
  end

  scenario 'communication method and time fields are cached' do
    stub_request(
      :get, intake_api_url(ExternalRoutes.intake_api_screening_path(existing_screening.id))
    ).and_return(json_body(existing_screening.to_json, status: 200))
    stub_request(
      :put, intake_api_url(ExternalRoutes.intake_api_screening_path(existing_screening.id))
    ).and_return(json_body(existing_screening.to_json, status: 200))
    stub_empty_relationships_for_screening(existing_screening)
    stub_empty_history_for_screening(existing_screening)
    visit edit_screening_path(id: existing_screening.id)

    reported_on = Date.today
    communication_method = 'Child Abuse Form'

    within '#cross-report-card' do
      select 'State of California', from: 'County'
      find('label', text: /\ACounty licensing\z/).click
      fill_in_datepicker 'Cross Reported on Date', with: reported_on
      select communication_method, from: 'Communication Method'
      find('label', text: /\ACounty licensing\z/).click
      find('label', text: /\ALaw enforcement\z/).click
      expect(page).to have_field('Cross Reported on Date', with: reported_on.strftime('%m/%d/%Y'))
      expect(page).to have_field('Communication Method', with: communication_method)

      click_button 'Save'
    end

    expect(
      a_request(
        :put, intake_api_url(ExternalRoutes.intake_api_screening_path(existing_screening.id))
      ).with(
        body: hash_including(
          'cross_reports' => array_including(
            hash_including(
              'agencies' => array_including(
                hash_including('id' => '', 'type' => 'LAW_ENFORCEMENT')
              ),
              'inform_date' => reported_on.to_s(:db),
              'method' => communication_method
            )
          )
        )
      )
    ).to have_been_made
  end

  scenario 'communication method and time fields are cleared after county change' do
    stub_request(
      :get, intake_api_url(ExternalRoutes.intake_api_screening_path(existing_screening.id))
    ).and_return(json_body(existing_screening.to_json, status: 200))
    stub_request(
      :put, intake_api_url(ExternalRoutes.intake_api_screening_path(existing_screening.id))
    ).and_return(json_body(existing_screening.to_json, status: 200))
    stub_empty_relationships_for_screening(existing_screening)
    stub_empty_history_for_screening(existing_screening)
    visit edit_screening_path(id: existing_screening.id)

    reported_on = Date.today
    communication_method = 'Child Abuse Form'

    within '#cross-report-card' do
      select 'San Francisco', from: 'County'
      find('label', text: /\ACounty licensing\z/).click
      fill_in_datepicker 'Cross Reported on Date', with: reported_on
      select communication_method, from: 'Communication Method'
      find('label', text: /\ACounty licensing\z/).click
      find('label', text: /\ALaw enforcement\z/).click
      expect(page).to have_field('Cross Reported on Date', with: reported_on.strftime('%m/%d/%Y'))
      expect(page).to have_field('Communication Method', with: communication_method)
      select 'State of California', from: 'County'
      find('label', text: /\ALaw enforcement\z/).click
      expect(page)
        .to_not have_field('Cross Reported on Date', with: reported_on.strftime('%m/%d/%Y'))
      expect(page).to_not have_field('Communication Method', with: communication_method)

      click_button 'Save'
    end

    expect(
      a_request(
        :put, intake_api_url(ExternalRoutes.intake_api_screening_path(existing_screening.id))
      ).with(
        body: hash_including(
          'cross_reports' => array_including(
            hash_including(
              'agencies' => array_including(
                hash_including('id' => '', 'type' => 'LAW_ENFORCEMENT')
              ),
              'inform_date' => nil,
              'method' => nil
            )
          )
        )
      )
    ).to have_been_made
  end

  scenario 'communication method and time fields are cleared from cache after save' do
    stub_request(
      :get, intake_api_url(ExternalRoutes.intake_api_screening_path(existing_screening.id))
    ).and_return(json_body(existing_screening.to_json, status: 200))
    stub_request(
      :put, intake_api_url(ExternalRoutes.intake_api_screening_path(existing_screening.id))
    ).and_return(json_body(existing_screening.to_json, status: 200))
    stub_empty_relationships_for_screening(existing_screening)
    stub_empty_history_for_screening(existing_screening)
    visit edit_screening_path(id: existing_screening.id)

    reported_on = Date.today
    communication_method = 'Child Abuse Form'

    within '#cross-report-card' do
      select 'State of California', from: 'County'
      find('label', text: /\ACounty licensing\z/).click
      fill_in_datepicker 'Cross Reported on Date', with: reported_on
      select communication_method, from: 'Communication Method'
      find('label', text: /\ACounty licensing\z/).click
      click_button 'Save'
    end

    click_link 'Edit cross report'

    within '#cross-report-card' do
      select 'State of California', from: 'County'
      find('label', text: /\ACounty licensing\z/).click
      expect(page).to have_field('Cross Reported on Date', with: '')
      expect(page).to have_field('Communication Method', with: '')
    end
  end
end
