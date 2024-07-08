class Api::V1::InstrumentsController < Api::V1::BaseController
    before_action :set_instrument, only: [:show, :update, :destroy]

    def index
    end
  
    def show
    end

    private

    def set_instrument
      @instrument = Instrument.find(params[:id])
    end
end
