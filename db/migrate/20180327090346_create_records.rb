class CreateRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :records do |t|
      t.integer :cosmin_id
      t.text :abstract
      t.text :accnum
      t.text :author
      t.text :bpv
      t.boolean :cu
      t.text :disease
      t.text :doi
      t.text :fs
      t.text :ghp
      t.text :instrument
      t.text :issn
      t.text :issue
      t.text :journal
      t.text :oc
      t.text :oql
      t.text :pnp
      t.text :age
      t.integer :pubyear
      t.text :ss
      t.text :startpage
      t.text :title
      t.text :tmi
      t.text :url
      t.text :user_email
      t.timestamps
    end
  end
end
