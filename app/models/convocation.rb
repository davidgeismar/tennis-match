class Convocation < ActiveRecord::Base
  extend Enumerize
  enumerize :status, in: [:pending, :confirmed, :refused, :cancelled]

  belongs_to  :subscription

  has_many    :messages

  validates :date,            presence: { message: "Veuillez remplir la date de la convocation" }, on: :create
  validates :hour,            presence: { message: "Veuillez remplir l'heure de votre convocation" }, on: :create
  validates :subscription_id, presence: true
end
