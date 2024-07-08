json.extract! instrument, :id, :user_id, :title, :body, :created_at, :updated_at
json.url api_v1_instrument_url(instrument, format: :json)
