class Competition < ActiveRecord::Base
  extend Enumerize
  enumerize :category,    in: Settings.enumerize.categories
  enumerize :genre,       in: Settings.enumerize.genre
  enumerize :max_ranking, in: Settings.enumerize.ranking
  enumerize :min_ranking, in: Settings.enumerize.ranking
  enumerize :nature,      in: ['Simple']

  belongs_to :tournament
  has_many :subscriptions,  dependent: :destroy
  has_many :transfers,      dependent: :destroy


  validates :category,            presence: { message: "Merci d'indiquer une catégorie de l'épreuve" }
  validates :nature,              presence: { message: "Merci d'indiquer la nature de l'épreuve" }
  validates :genre,               presence: { message: "Merci d'indiquer le genre de l'épreuve" }

  def in_ranking_range(user_ranking, competition)
    ranking_value = Settings.user_ranking_value[user_ranking]
    competition_max_ranking_value = Settings.user_ranking_value[competition.max_ranking]
    competition_min_ranking_value = Settings.user_ranking_value[competition.min_ranking]
    if competition_max_ranking_value >= ranking_value && ranking_value >= competition_min_ranking_value
      return true
    else
      return false
    end
  end

  def open_for_ranking?(user_ranking)
    ranking_field_name = Settings.user_competition_ranking_matching[user_ranking]
    ranking_acceptance = self[ranking_field_name]
    (total && ranking_acceptance) == true
  end

  def open_for_genre?(user_genre)
    self.genre == user_genre
  end
  def open_for_birthdate?(user_birthdate)
    birth_year        = user_birthdate.year
    user_age          = Date.today.year - birth_year

    check_settings    = Settings.tournament_category_checks
    real_age          = check_settings.real_age[category]
    exact_tennis_age  = check_settings.exact_tennis_age[category]
    range_tennis_age  = check_settings.range_tennis_age[category]
    senior_tennis_age = check_settings.senior_tennis_age[category]

    return false if user_age <= 7
    return false if real_age          && real_age != user_age
    return false if exact_tennis_age  && (tennis_year - exact_tennis_age) != birth_year
    return false if range_tennis_age  && (tennis_year - range_tennis_age) != birth_year && (tennis_year - range_tennis_age - 1) != birth_year
    return false if senior_tennis_age && (tennis_year - senior_tennis_age) < birth_year

    true
  end
end