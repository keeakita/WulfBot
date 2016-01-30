require 'active_record'

module Points

  db_name =  ENV['RAILS_ENV'] || 'development'
  ActiveRecord::Base.establish_connection(
    YAML::load(
      File.open('db/config.yml')
    )[db_name])

  # An array of {group userid target time} hashes tracking when a given user
  # voted for a given target in a given group most recently. Used for rate
  # limiting.
  @@last_upvoted = []
  @@last_downvoted = []

  # Time to wait (in seconds) before letting a user vote again
  VOTE_COOLDOWN = 30

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

  private_class_method(
  def self.searchVoteTimes(group, userid, target, upvote: true)
    array = upvote ? @@last_upvoted : @@last_downvoted

    return array.select do |item|
      group == item[:group] &&
        userid == item[:userid] &&
        target == item[:target]
    end
  end)

  # Checks if the given user is allowed to vote for the target in the group
  # based on the rate limit. By default checks for upvote ability, set upvote:
  # false in order to check for downvote ability
  def self.canVote?(group, userid, target, upvote: true)
    vote_time = Time.now

    records = searchVoteTimes(group, userid, target, upvote: upvote)

    return true if records.empty?
    return vote_time > (records.first[:time] + VOTE_COOLDOWN)
  end

  # Store a successful vote attempt in the rate limit tracking caches. Defaults
  # to tracking upvotes, set upvote: false in order to track downvotes
  def self.registerVoteTime(group, userid, target, upvote: true)
    # Search for an existing record and update the time if applicable
    records = searchVoteTimes(group, userid, target, upvote: upvote)

    if (records.empty?)
      # Create a new record
      array = upvote ? @@last_upvoted : @@last_downvoted
      array << {group: group, userid: userid, target: target, time: Time.now}
    else
      # Update existing record
      records.first[:time] = Time.now
    end
  end
end
