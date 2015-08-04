class User < ActiveRecord::Base
  extend Enumerize

  enumerize :genre,   in: [:male, :female]
  enumerize :ranking, in: ['NC', '40', '30/5', '30/4', '30/3', '30/2', '30/1', '30', '15/5', '15/4', '15/3', '15/2', '15/1', '15', '5/6', '4/6', '3/6', '2/6', '1/6', '0', '-2/6', '-4/6', '-15', '-30']

  devise :invitable,
          :database_authenticatable,
          :registerable,
          :confirmable,
          :recoverable,
          :rememberable,
          :trackable,
          :validatable,
          :omniauthable, omniauth_providers:  [:facebook]

  has_many :subscriptions,  dependent: :destroy
  has_many :tournaments,    dependent: :destroy
  has_many :messages,       dependent: :destroy
  has_many :notifications,  dependent: :destroy

  has_attached_file :picture,           styles: { medium: "300x300>", thumb: "100x100>" }
  has_attached_file :licencepicture,    styles: { medium: "300x300>", thumb: "100x100>" }
  has_attached_file :certifmedpicture,  styles: { medium: "300x300>", thumb: "100x100>" }

  validates_attachment_content_type :picture,           content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :licencepicture,    content_type: /\Aimage\/.*\z/
  validates_attachment_content_type :certifmedpicture,  content_type: /\Aimage\/.*\z/

  validates :first_name,  presence: { message: 'Veuillez remplir votre prénom' }, on: :update
  validates :last_name,   presence: { message: 'Veuillez remplir votre nom' },    on: :update

  validates :licence_number, format: {
      with:     /\d{7}\D{1}/,
      message:  'Le format de votre numéro de licence doit être du type 0930613K'
    }, on: :update

  validates :telephone, format: {
      with:     /\A(\+33)[1-9]([-. ]?[0-9]{2}){4}\z/,
      message:  'Le format de votre numéro doit être du type +33602385414'
    }, allow_blank: true, on: :update

  # after_create :send_welcome_email, unless: :invitation_token

  def self.find_for_facebook_oauth(auth)
    user    = where(email: auth.info.email).first
    user  ||= where(provider: auth.provider, uid: auth.uid).first_or_initialize
    user.skip_confirmation!

    user.provider     = auth.provider
    user.uid          = auth.uid
    user.email        = auth.info.email
    user.password     = Devise.friendly_token[0,20]
    user.first_name   = auth.info.first_name
    user.last_name    = auth.info.last_name
    user.picture      = auth.info.image
    user.token        = auth.credentials.token
    user.token_expiry = Time.at(auth.credentials.expires_at)

    user.save

    user
  end

  def age
    now = Time.now.utc.to_date
    now.year - birthdate.year - (birthdate.to_date.change(:year => now.year) > now ? 1 : 0)
  end

  def full_name
    if last_name && first_name.nil?
      last_name.capitalize
    elsif first_name && last_name.nil?
      first_name.capitalize
    elsif last_name.nil? && first_name.nil?
      ""
    else
      "#{first_name.capitalize} #{last_name.capitalize}"
    end
  end

  def full_name_inversed
    if last_name && first_name.nil?
      last_name.capitalize
    elsif first_name && last_name.nil?
      first_name.capitalize
    elsif last_name.nil? && first_name.nil?
      ""
    else
      "#{last_name.capitalize} #{first_name.capitalize}"
    end
  end

  def licence_number_custom
   licence_without_white_space = licence_number.split.join
   return licence_without_white_space[0...-1]
  end

  def profile_complete?
    base_fields_complete = (first_name.present? &&
      last_name.present? &&
      telephone.present? &&
      birthdate.present? &&
      licence_number.present?
    )

    if judge
      return base_fields_complete && address.present?
    else
      return base_fields_complete && genre.present? && club.present? && ranking.present?
    end
  end

  private

  # def send_welcome_email
  #   if self.judge?
  #     UserMailer.welcome_judge(self).deliver
  #   else
  #     UserMailer.welcome(self).deliver
  #   end
  # end
end
