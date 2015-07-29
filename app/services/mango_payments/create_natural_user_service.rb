module MangoPayments
  class CreateNaturalUserService
    def initialize(user)
      @user = user
    end

    def call
      mango_user = MangoPay::NaturalUser.create(
        Email:              @user.email,
        FirstName:          @user.first_name,
        LastName:           @user.last_name,
        Birthday:           @user.birthdate.to_i,
        Nationality:        'FR', # TODO: change this.
        CountryOfResidence: 'FR'  # TODO: change this.
      )

      @user.mango_user_id = mango_user['Id']
      @user.save
    end
  end
end

