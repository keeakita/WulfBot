require 'active_record'

module Points

  db_name =  ENV['RAILS_ENV'] || 'development'
  ActiveRecord::Base.establish_connection(
    YAML::load(
      File.open('db/config.yml')
    )[db_name])

  # An array of {group userid time} hashes tracking when a given user voted in
  # a given group most recently. Used for rate limiting.
  @@last_voted = []

  # Time to wait (in seconds) before letting a user vote again
  VOTE_COOLDOWN = 900

  # An ActiveRecord class representing the score for a given user
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

  # Checks if the given user is allowed to vote for the target in the group
  # based on the rate limit.
  def self.canVote?(group, userid)
    vote_time = Time.now

    records = @@last_voted.select do |item|
      group == item[:group] && userid == item[:userid]
    end

    return true if records.empty?
    return vote_time > (records.first[:time] + VOTE_COOLDOWN)
  end

  # Store a successful vote attempt in the rate limit tracking caches.
  def self.registerVoteTime(group, userid)
    # Search for an existing record and update the time if applicable
    records = @@last_voted.select do |item|
      group == item[:group] && userid == item[:userid]
    end

    if (records.empty?)
      # Create a new record
      @@last_voted << {group: group, userid: userid, time: Time.now}
    else
      # Update existing record
      records.first[:time] = Time.now
    end
  end
end
