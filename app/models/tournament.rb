class Tournament < ActiveRecord::Base
  has_many :transfers
  geocoded_by :address_tour
  after_validation :geocode, if: :address_tour_changed?

  def address_tour
    "#{address} #{city}"
  end

  def address_tour_changed?
    address_changed? || city_changed?
  end

  include AlgoliaSearch
  algoliasearch index_name: "tournament#{ENV['ALGOLIA_SUFFIX']}" do
    attribute :genre, :category, :starts_on, :ends_on, :address, :city, :name, :club_organisateur
    attributesToIndex ['city', 'address', 'club_organisateur','starts_on', 'ends_on', 'category', 'name']
  end

  extend Enumerize
  enumerize :genre, in: [:male, :female]
  enumerize :category, in: ['seniors', '35 ans', '40 ans', '45 ans', '50 ans', '55 ans', '60 ans', '70 ans', '75 ans', '80 ans', '9 ans', '9-10ans', '10 ans', '11 ans', '11-12 ans', '12 ans', '13-14 ans', '15-16 ans', '17-18 ans']


  belongs_to :user

  has_many :subscriptions, dependent: :destroy

  validates :genre, presence: true
  validates :category, presence: true
  validates :starts_on, presence: true
  validates :ends_on, presence: true
end


