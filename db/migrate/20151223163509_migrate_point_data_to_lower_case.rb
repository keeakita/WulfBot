require_relative '../../lib/points'

class MigratePointDataToLowerCase < ActiveRecord::Migration
  def up
    Points::PointRecord.find_each do |record|
      # Check the case of the record
      if record.user != record.user.downcase
        # Load the correct record and update it
        lower_rec = Points::PointRecord.where(user: record.user.downcase).take

        if lower_rec.nil?
          # Change the username of this record to lowercase
          record.user.downcase!
          record.save!
        else
          # Update existing record
          lower_rec.upvotes += record.upvotes
          lower_rec.downvotes += record.downvotes

          # Save the lower case record and destroy the upercase
          lower_rec.save!
          record.destroy!
        end

      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
