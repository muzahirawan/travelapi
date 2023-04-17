class AddLocationToRoutes < ActiveRecord::Migration[7.0]
  def change
    add_reference :routes, :location, null: false, foreign_key: true
  end
end
