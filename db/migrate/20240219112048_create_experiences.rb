# frozen_string_literal: true

class CreateExperiences < ActiveRecord::Migration[7.0]
  def change
    create_table :experiences do |t|
      t.references :profile, null: false, foreign_key: true

      t.string  :title_en
      t.string  :title_fr
      t.string  :title_it
      t.string  :title_de
      t.string  :location
      t.integer :year_begin, null: false
      t.integer :year_end, null: true
      t.integer :position, null: false
      t.integer :audience, default: 0 # 0=public, 1=intranet, 2=authenticated user, 3=me (draft)
      t.boolean :visible, default: false
      t.timestamps
    end
    add_index :experiences, %i[profile_id position], unique: true
  end
end
