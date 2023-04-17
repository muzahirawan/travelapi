class CreateRoutes < ActiveRecord::Migration[7.0]
  def change
    create_table :routes do |t|
      t.string :origin
      t.string :destination
      t.string :routeSummary
      t.string :travelTime
      t.string :trevelMode
      t.string :travelDistance

      t.timestamps
    end
  end
end
