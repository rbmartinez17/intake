# frozen_string_literal: true

# Screening Controller handles all service request for
# the creation and modification of screening objects.
class ScreeningsController < ApplicationController # :nodoc:
  PERMITTED_PARAMS = [
    :communication_method,
    :ended_at,
    :id,
    :incident_county,
    :incident_date,
    :location_type,
    :name,
    :reference,
    :report_narrative,
    :response_time,
    :screening_decision,
    :started_at,
    address: [
      :id,
      :city,
      :state,
      :street_address,
      :zip
    ],
    participant_ids: []
  ].freeze

  def create
    new_screening = Screening.new(reference: LUID.generate.first)
    @screening = ScreeningRepository.create(new_screening)
    redirect_to edit_screening_path(@screening.id)
  end

  def update
    existing_screening = Screening.new(screening_params.to_h)
    @screening = ScreeningRepository.update(existing_screening)
    redirect_to screening_path(@screening.id)
  end

  def edit
    @screening = ScreeningRepository.find(params[:id])
    @participants = @screening.participants.to_a
  end

  def show
    @screening = ScreeningRepository.find(params[:id])
    @participants = @screening.participants.to_a
  end

  def index
    respond_to do |format|
      format.html
      format.json do
        screenings = ScreeningsRepo.search(query).results
        render json: screenings
      end
    end
  end

  private

  def query
    { query: { filtered: { filter: { bool: { must: search_terms } } } } }
  end

  def search_terms
    terms = []

    terms << { terms: { response_time: response_times } } if response_times
    terms << { terms: { screening_decision: screening_decisions } } if screening_decisions

    terms
  end

  def response_times
    params[:response_times]
  end

  def screening_decisions
    params[:screening_decisions]
  end

  def screening_params
    params.require(:screening).permit(*PERMITTED_PARAMS)
  end
end