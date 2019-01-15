json.extract! instrument, :id, :name, :url1, :url2, :url3, :url4, :created_at, :updated_at
json.url instrument_url(instrument, format: :json)
