class RecreateInstruments < ActiveRecord::Migration[5.0]
    def change

      drop_table :instruments
      drop_table :instruments_records

      create_table :instruments do |t|
        t.text :name
        t.text :reference
        t.text :doi
        t.text :pmid
        t.text :refurl
        t.text :url1
        t.text :url2
        t.text :url3
        t.timestamps
      end

      create_table :instruments_records, id: false do |t|
        t.belongs_to :record, foreign_key: true
        t.belongs_to :instrument, foreign_key: true
      end
      add_index :instruments_records, [:instrument_id, :record_id], :unique => true, :name => 'by_instruments_and_records'
    end


end