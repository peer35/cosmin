class CreateInstruments < ActiveRecord::Migration[5.0]
  def change
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
      t.belongs_to :record, index: true
      t.belongs_to :instrument, index: true
    end
  end
end
