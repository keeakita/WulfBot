require 'active_record'

module Points

  db_name =  ENV['RAILS_ENV'] || 'development'
  ActiveRecord::Base.establish_connection(
    YAML::load(
      File.open('db/config.yml')
    )[db_name])

  class PointRecord < ActiveRecord::Base

    def score
      self.upvotes - self.downvotes
    end

    def addpoint
      self.upvotes += 1
    end

    def addpoint!
      addpoint
      save!
    end

    def rmpoint
      self.downvotes += 1
    end

    def rmpoint!
      rmpoint
      save!
    end

    def to_s
      "#{user}: #{score} (+#{upvotes}/-#{downvotes})"
    end
  end

  def self.getPointRecord(group, user)
    PointRecord.where(group: group, user: user.downcase).take
  end

  def self.topScores(group, number=5)
    PointRecord.where(group: group)
               .select('*, upvotes-downvotes as score')
               .order('score DESC')
               .limit(number)
  end

  def self.bottomScores(group, number=5)
    PointRecord.where(group: group)
               .select('*, upvotes-downvotes as score')
               .order('score ASC')
               .limit(number)
  end
end
