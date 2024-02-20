# frozen_string_literal: true

class CreateExperiences < ActiveRecord::Migration[7.0]
  def change
    create_table :experiences do |t|
      t.references :profile, null: false, foreign_key: true

      t.string  :title_en
      t.string  :title_fr
      t.string  :location
      t.integer :year_begin, null: false
      t.integer :year_end, null: true
      t.integer :audience, default: 0 # 0=public, 1=intranet, 2=authenticated user
      t.boolean :visible, default: false

      t.timestamps
    end
  end
end
