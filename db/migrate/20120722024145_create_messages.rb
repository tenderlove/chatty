class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :value
      t.string :who
      t.string :uid

      t.timestamps
    end
  end
end
