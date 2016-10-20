# frozen_string_literal: true
require 'rails_helper'

feature 'Create Screening' do
  scenario 'via start screening link' do
    screening = {
      id: 1,
      reference: 'MYREFERENCE',
      address: {
      },
      participants: []
    }.with_indifferent_access

    faraday_stub = Faraday.new do |builder|
      builder.adapter :test do |stub|
        stub.post('/api/v1/screenings') do |_|
          [201, {}, screening]
        end
        stub.get('/api/v1/screenings/1') do |_|
          [200, {}, screening]
        end
      end
    end
    allow(API).to receive(:connection).and_return(faraday_stub)

    visit root_path
    click_link 'Start Screening'
    expect(page).to have_content('Edit Screening #MYREFERENCE')
  end
end
