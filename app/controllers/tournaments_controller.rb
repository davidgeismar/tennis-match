 class TournamentsController < ApplicationController
  before_action :set_tournament,  only: [:update, :edit, :show]
  before_action :check_profile,   only: [:create]

  def index
    @tournaments = policy_scope(Tournament)
    if @tournaments.blank? && current_user.judge?
      render 'pages/partials/_no_tournaments_judge'
    elsif @tournaments.blank?
      render 'pages/partials/_no_tournaments'
    end
  end

  def show
    if Time.now.utc.to_date > @tournament.ends_on
      flash[:alert] = "Le tournoi que vous cherchez est terminé."
      redirect_to root_path
    end
    @markers = Gmaps4rails.build_markers(@tournament) do |tournament, marker|
      marker.lat tournament.latitude
      marker.lng tournament.longitude
    end
    authorize @tournament
  end

  def new
    @tournament = Tournament.new
    authorize @tournament
    check_profile
  end

  def create
    @tournament                     = Tournament.new(tournament_params)
    @tournament.user                = current_user
    @tournament.homologation_number = params[:tournament][:homologation_number].split.join
    authorize @tournament


    service = MangoPayments::Tournaments::SetupService.new(@tournament)
    if @tournament.save && service.call
      redirect_to tournament_path(@tournament)
    else
      render :new
    end
  rescue MangoPay::ResponseError => e
    @tournament.destroy
    flash.now[:alert] = "L'IBAN ou le BIC que vous avez fourni n'est pas valide. Veuillez vérifier les informations fournies. Si le problème persiste n'hésitez pas à contacter l'équipe WeTennis."
    render :new
  end

  def edit
    authorize @tournament
  end

  def update
    authorize @tournament
    @tournament.update(tournament_params)
    @tournament.accepted = false
    if @tournament.save
      redirect_to tournament_path(@tournament)
    else
      render :edit
    end
  end

  private

  def check_profile
    if !current_user.profile_complete?
      flash[:alert] = "Vous devez d'abord remplir" + "<a href=#{user_path(current_user)} class='profil_link'>" + " votre profil " + "</a>"  + "entièrement pour pouvoir ajouter votre tournoi"
      redirect_to root_path
    elsif !current_user.accepted
      flash[:alert] = "Votre compte Juge Arbitre doit d'abord avoir été accepté par l'équipe WeTennis avant de pouvoir ajouter un tournoi. Assurez vous d'avoir bien rempli intégralement" + "<a href=#{user_path(current_user)} class='profil_link'>" + "votre profil" + "</a>" + "afin d'avoir une réponse rapide."
      redirect_to root_path
    end
  end

  def set_tournament
    @tournament = Tournament.find(params[:id])
  end

  def tournament_params
    params.require(:tournament).permit(
      :address,
      :amount,
      :bic,
      :cinqsix,
      :city,
      :club_email,
      :club_organisateur,
      :ends_on,
      :genre,
      :homologation_number,
      :iban,
      :lat,
      :long,
      :name,
      :NC,
      :postcode,
      :starts_on,
      :young_fare,
      :club_fare
    )
  end
end
