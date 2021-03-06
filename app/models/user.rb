  class User < ApplicationRecord
    has_many :microposts, dependent: :destroy
    attr_accessor :remember_token, :activation_token, :reset_token
    before_save :email_downcase
    before_create :create_activation_digest

    validates :name, presence: true, length: {maximum: 50}

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: {maximum: 255},
      format: {with: VALID_EMAIL_REGEX},
      uniqueness: {case_sensitive: false}
    has_secure_password
    validates :password, presence: true, length: {minimum: 6}

    VALID_PHONE_NUMBER_REGEX = /0\d{9,10}/
    validates :phone_number, presence: true,
      format: {with: VALID_PHONE_NUMBER_REGEX}

    scope :activated, ->{where("activated = ?", true)}

    class << self
      def digest string
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
          BCrypt::Engine.cost
        BCrypt::Password.create string, cost: cost
      end

      def new_token
        SecureRandom.urlsafe_base64
      end
    end

    def feeds
      microposts.order_by_time
    end

    def create_reset_digest
      self.reset_token = User.new_token
      update_columns reset_digest: User.digest(reset_token),
        reset_sent_at: Time.zone.now
    end

    def send_password_reset_email
      UserMailer.password_reset(self).deliver_now
    end

    def correct_user? current_user
      self == current_user
    end

    def remember
      self.remember_token = User.new_token
      update_attribute :remember_digest, User.digest(remember_token)
    end

    def authenticated? attribute, token
      digest = send "#{attribute}_digest"
      return false if digest.nil?
      BCrypt::Password.new(digest).is_password?(token)
    end

    def forget
      update_attribute :remember_digest, nil
    end

    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest activation_token
    end

    def activate
      update_columns activated: true, activated_at: Time.zone.now
    end

    def send_activation_email
      UserMailer.account_activation(self).deliver_now
    end

    def password_reset_expired?
      reset_sent_at < 2.hours.ago
    end

    private
    def email_downcase
      self.email = email.downcase
    end
  end
