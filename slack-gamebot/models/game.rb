class Game
  include Mongoid::Document
  include Mongoid::Timestamps

  SORT_ORDERS = ['created_at', '-created_at', 'updated_at', '-updated_at']

  field :name, type: String
  index(name: 1)

  field :bot_name, type: String
  field :client_id, type: String
  field :client_secret, type: String
  field :aliases, type: Array, default: []

  validates_uniqueness_of :client_id, message: 'already exists'

  has_many :teams

  def users
    User.where(:team_id.in => teams.distinct(:_id))
  end

  def matches
    Match.where(:team_id.in => teams.distinct(:_id))
  end

  def challenges
    Challenge.where(:team_id.in => teams.distinct(:_id))
  end

  def seasons
    Season.where(:team_id.in => teams.distinct(:_id))
  end

  def to_s
    "name=#{name}, client_id=#{client_id}, aliases=#{aliases}"
  end

  def self.find_or_create_from_env!
    client_id = ENV['SLACK_CLIENT_ID']
    client_secret = ENV['SLACK_CLIENT_SECRET']
    return unless client_id && client_secret
    game = Game.where(client_id: client_id).first
    game ||= Game.new(client_id: client_id)
    game.client_id = client_id
    game.client_secret = client_secret
    game.aliases = ENV['SLACK_RUBY_BOT_ALIASES'].split if ENV.key?('SLACK_RUBY_BOT_ALIASES')
    game.save!
    game
  end
end