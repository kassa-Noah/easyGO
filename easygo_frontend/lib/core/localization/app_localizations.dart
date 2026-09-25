import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final AppLocalizations? result = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );

    assert(
      result != null,
      'AppLocalizations was not found in the widget tree.',
    );

    return result!;
  }

  static const List<Locale> supportedLocales = [Locale('en'), Locale('fr')];

  bool get isFrench => locale.languageCode == 'fr';

  String get appName => 'easyGO';

  String get tagline => isFrench
      ? 'Voyagez. Suivez. Arrivez en toute sérénité.'
      : 'Travel. Track. Arrive with Ease.';

  // ==================================================
  // GENERAL
  // ==================================================

  String get close => isFrench ? 'Fermer' : 'Close';
  String get cancel => isFrench ? 'Annuler' : 'Cancel';
  String get logout => isFrench ? 'Déconnexion' : 'Logout';
  String get settings => isFrench ? 'Paramètres' : 'Settings';
  String get notifications => 'Notifications';
  String get today => isFrench ? 'Aujourd’hui' : 'Today';
  String get send => isFrench ? 'Envoyer' : 'Send';
  String get select => isFrench ? 'Sélectionner' : 'Select';

  // ==================================================
  // MAIN NAVIGATION
  // ==================================================

  String get home => isFrench ? 'Accueil' : 'Home';
  String get trips => isFrench ? 'Voyages' : 'Trips';
  String get track => isFrench ? 'Suivi' : 'Track';
  String get profile => isFrench ? 'Profil' : 'Profile';

  // ==================================================
  // CLIENT HOME
  // ==================================================

  String get transportAgencies =>
      isFrench ? 'Agences de transport' : 'Transport Agencies';

  String get agencySectionDescription => isFrench
      ? 'Choisissez une agence et découvrez les services disponibles.'
      : 'Choose an agency and explore available services.';

  String get searchAgencyHint => isFrench
      ? 'Rechercher une agence, une ville ou un service'
      : 'Search agency, city or service';

  String get clearSearch => isFrench ? 'Effacer la recherche' : 'Clear Search';

  String get clearSearchTooltip =>
      isFrench ? 'Effacer la recherche' : 'Clear search';

  String get filterAll => isFrench ? 'Toutes' : 'All';

  String get filterTopRated => isFrench ? 'Mieux notées' : 'Top Rated';

  String get filterClosest => isFrench ? 'Plus proches' : 'Closest';

  String get filterPopular => isFrench ? 'Populaires' : 'Popular';

  String agenciesFound(int count) {
    return isFrench ? '$count trouvée${count > 1 ? 's' : ''}' : '$count found';
  }

  String get noAgenciesFound =>
      isFrench ? 'Aucune agence trouvée' : 'No Agencies Found';

  String get noAgenciesForFilter => isFrench
      ? 'Aucune agence de transport n’est disponible pour ce filtre.'
      : 'No transport agencies are available for this filter.';

  String noAgencyMatches(String query) {
    return isFrench
        ? 'Aucune agence ne correspond à "$query". Essayez une autre agence, ville ou service.'
        : 'No agency matches "$query". Try another agency, city or service.';
  }

  String reviews(int count) {
    return isFrench ? '$count avis' : '$count reviews';
  }

  String serviceLabel(String service) {
    switch (service) {
      case 'Interurban':
        return isFrench ? 'Interurbain' : 'Interurban';
      case 'Door-to-Door':
        return isFrench ? 'Porte-à-porte' : 'Door-to-Door';
      case 'Parcel':
        return isFrench ? 'Colis' : 'Parcel';
      default:
        return service;
    }
  }

  String filterLabel(String filter) {
    switch (filter) {
      case 'Top Rated':
        return filterTopRated;
      case 'Closest':
        return filterClosest;
      case 'Popular':
        return filterPopular;
      case 'All':
      default:
        return filterAll;
    }
  }

  // ==================================================
  // AGENCY DETAILS
  // ==================================================

  String get agencyDetails =>
      isFrench ? 'Détails de l’agence' : 'Agency Details';

  String get transportAgency =>
      isFrench ? 'Agence de transport' : 'Transport Agency';

  String get call => isFrench ? 'Appeler' : 'Call';

  /// Opens the list of branches with their addresses and coordinates. It does
  /// not calculate a route, so it is not labelled "Directions".
  String get branchLocations =>
      isFrench ? 'Emplacements' : 'Locations';

  String get share => isFrench ? 'Partager' : 'Share';
  String get message => 'Message';

  String get messageAgency =>
      isFrench ? 'Contacter l’agence' : 'Message Agency';

  String get aboutAgency => isFrench ? 'À propos de l’agence' : 'About Agency';

  String get aboutAgencyDescription => isFrench
      ? 'Services de transport interurbain fiables, avec des options de voyage confortables et des services orientés vers les besoins des clients.'
      : 'Reliable interurban transport services with comfortable travel options and customer-focused services.';

  String get services => 'Services';

  String get agencyInformation =>
      isFrench ? 'Informations sur l’agence' : 'Agency Information';

  String get popularRoutes =>
      isFrench ? 'Itinéraires populaires' : 'Popular Routes';

  String get customerReviews =>
      isFrench ? 'Avis des clients' : 'Customer Reviews';

  String get location => isFrench ? 'Localisation' : 'Location';
  String get phone => isFrench ? 'Téléphone' : 'Phone';

  String get openingHours => isFrench ? 'Heures d’ouverture' : 'Opening Hours';

  String get status => isFrench ? 'Statut' : 'Status';

  String get verifiedAgency => isFrench ? 'Agence vérifiée' : 'Verified Agency';

  String get agencyLocation =>
      isFrench ? 'Localisation de l’agence' : 'Agency Location';

  String get agencyAddress =>
      isFrench ? 'Adresse de l’agence' : 'Agency Address';

  String approximateDistance(String distance) {
    return isFrench
        ? 'Distance approximative : $distance'
        : 'Approximate distance: $distance';
  }

  String get notAvailable => isFrench ? 'Non disponible' : 'Not available';

  String get callIntegrationInfo => isFrench
      ? 'L’appel téléphonique direct sera connecté lors de l’intégration des services externes. Le numéro réel proviendra du profil de l’agence retourné par le backend.'
      : 'Direct phone launching will be connected during external-service integration. The production number will come from the agency profile returned by the backend.';

  String get shareAgency => isFrench ? 'Partager l’agence' : 'Share Agency';

  String get sharePreview => isFrench ? 'Aperçu du partage' : 'Share Preview';

  String get nativeSharingInfo => isFrench
      ? 'Le partage natif sera connecté lors de l’intégration des services externes.'
      : 'Native sharing will be connected during external-service integration.';

  String get rateReviewAgency =>
      isFrench ? 'Noter et donner un avis' : 'Rate & Review Agency';

  String get rateThisAgency =>
      isFrench ? 'Noter cette agence' : 'Rate This Agency';

  String get yourRating => isFrench ? 'Votre note' : 'Your Rating';

  String get review => isFrench ? 'Avis' : 'Review';

  String get reviewHint => isFrench
      ? 'Décrivez votre expérience avec cette agence'
      : 'Describe your experience with this agency';

  String get submitReview => isFrench ? 'Envoyer l’avis' : 'Submit Review';

  String get selectRatingError =>
      isFrench ? 'Veuillez sélectionner une note.' : 'Please select a rating.';

  String get enterReviewError =>
      isFrench ? 'Veuillez saisir un avis.' : 'Please enter a review.';

  String get reviewAdded => isFrench
      ? 'Avis ajouté à la démonstration frontend.'
      : 'Review added to the frontend demonstration.';

  String get demoReviewsInformation => isFrench
      ? 'Des avis de démonstration sont affichés pendant le développement frontend. Les avis réels seront récupérés depuis le backend.'
      : 'Demonstration reviews are shown during frontend development. Production reviews will be retrieved from the backend.';

  String agencyReviews(String agencyName) {
    return isFrench ? 'Avis sur $agencyName' : '$agencyName Reviews';
  }

  String basedOnReviews(int count) {
    return isFrench
        ? 'Basé sur $count avis de clients.'
        : 'Based on $count customer reviews.';
  }

  String get viewAll => isFrench ? 'Voir tout' : 'View All';

  String get bookTrip => isFrench ? 'Réserver un voyage' : 'Book a Trip';

  String priceFrom(String price) {
    return isFrench ? 'À partir de $price' : 'From $price';
  }

  // ==================================================
  // MESSAGING
  // ==================================================

  String conversationWith(String agencyName) {
    return isFrench
        ? 'Conversation avec $agencyName'
        : 'Conversation with $agencyName';
  }

  String get agencyStaff => isFrench ? 'Personnel de l’agence' : 'Agency Staff';

  String get typeMessage =>
      isFrench ? 'Écrire un message...' : 'Type a message...';

  String get noConversationsYet => isFrench
      ? 'Aucune conversation pour le moment.'
      : 'No conversations yet.';

  // ==================================================
  // ACCOUNT SECURITY
  // ==================================================

  String get changePassword =>
      isFrench ? 'Modifier le mot de passe' : 'Change Password';

  String get changePasswordSubtitle => isFrench
      ? 'Modifier votre mot de passe de connexion'
      : 'Update your sign-in password';

  // ==================================================
  // BOOKING MODE
  // ==================================================

  String get howWouldYouLikeToTravel => isFrench
      ? 'Comment souhaitez-vous voyager ?'
      : 'How would you like to travel?';

  String get chooseTravelService => isFrench
      ? 'Choisissez le service qui correspond le mieux à votre trajet.'
      : 'Choose the service that best matches your journey.';

  String get doorToDoor => isFrench ? 'Porte-à-porte' : 'Door-to-Door';

  String get doorToDoorDescription => isFrench
      ? 'Un voyage complet depuis votre lieu de prise en charge jusqu’à votre destination finale.'
      : 'Complete journey from your pickup location to your final destination.';

  String get completeJourney =>
      isFrench ? 'Voyage complet' : 'Complete Journey';

  String get pickupTaxi => isFrench ? 'Taxi de prise en charge' : 'Pickup taxi';

  String get interurbanTransport =>
      isFrench ? 'Transport interurbain' : 'Interurban transport';

  String get destinationTaxi =>
      isFrench ? 'Taxi vers la destination' : 'Destination taxi';

  String get interurbanOnly =>
      isFrench ? 'Interurbain uniquement' : 'Interurban Only';

  String get interurbanOnlyDescription => isFrench
      ? 'Réservez uniquement le transport interurbain entre les agences de départ et d’arrivée.'
      : 'Book only the interurban transport between agency stations.';

  String get busOnly =>
      isFrench ? 'Transport interurbain uniquement' : 'Bus Only';

  String get departureAgency =>
      isFrench ? 'Agence de départ' : 'Departure agency';

  String get arrivalAgency => isFrench ? 'Agence d’arrivée' : 'Arrival agency';

  String get taxiDoorToDoorInformation => isFrench
      ? 'Les services de taxi sont inclus uniquement lorsque vous choisissez le mode Porte-à-porte.'
      : 'Taxi services are included only when you choose Door-to-Door.';

  // ==================================================
  // JOURNEY SEARCH
  // ==================================================

  String get doorToDoorJourney =>
      isFrench ? 'Voyage porte-à-porte' : 'Door-to-Door Journey';

  String get interurbanJourney =>
      isFrench ? 'Voyage interurbain' : 'Interurban Journey';

  String get doorToDoorService =>
      isFrench ? 'Service porte-à-porte' : 'Door-to-Door Service';

  String get journeyDetails =>
      isFrench ? 'Détails du trajet' : 'Journey Details';

  String get journeyDetailsDescription => isFrench
      ? 'Indiquez les informations nécessaires pour rechercher les voyages disponibles.'
      : 'Provide the information required to search for available trips.';

  String get pickupLocation =>
      isFrench ? 'Lieu de prise en charge' : 'Pickup Location';

  String get pickupLocationHint => isFrench
      ? 'Entrez votre lieu de prise en charge'
      : 'Enter your pickup location';

  String get pickupLocationRequired => isFrench
      ? 'Veuillez entrer votre lieu de prise en charge.'
      : 'Please enter your pickup location.';

  String get departureCity => isFrench ? 'Ville de départ' : 'Departure City';

  String get selectDepartureCity =>
      isFrench ? 'Sélectionnez la ville de départ' : 'Select departure city';

  String get departureCityRequired => isFrench
      ? 'Veuillez sélectionner une ville de départ.'
      : 'Please select a departure city.';

  String get destinationCity =>
      isFrench ? 'Ville de destination' : 'Destination City';

  String get selectDestinationCity => isFrench
      ? 'Sélectionnez la ville de destination'
      : 'Select destination city';

  String get destinationCityRequired => isFrench
      ? 'Veuillez sélectionner une ville de destination.'
      : 'Please select a destination city.';

  String get finalDestination =>
      isFrench ? 'Destination finale' : 'Final Destination';

  String get finalDestinationHint => isFrench
      ? 'Entrez votre destination finale'
      : 'Enter your final destination';

  String get finalDestinationRequired => isFrench
      ? 'Veuillez entrer votre destination finale.'
      : 'Please enter your final destination.';

  String get travelDate => isFrench ? 'Date du voyage' : 'Travel Date';

  String get selectTravelDate =>
      isFrench ? 'Sélectionnez la date du voyage' : 'Select travel date';

  String get travelDateRequired => isFrench
      ? 'Veuillez sélectionner la date de votre voyage.'
      : 'Please select your travel date.';

  String get citiesMustBeDifferent => isFrench
      ? 'Les villes de départ et de destination doivent être différentes.'
      : 'Departure and destination cities must be different.';

  String get passengers => isFrench ? 'Passagers' : 'Passengers';

  String get passengersDescription => isFrench
      ? 'Nombre de personnes qui voyagent'
      : 'Number of people travelling';

  String get luggage => isFrench ? 'Bagages' : 'Luggage';

  String get luggageDescription =>
      isFrench ? 'Nombre de bagages' : 'Number of luggage items';

  String get searchAvailableTrips => isFrench
      ? 'Rechercher les voyages disponibles'
      : 'Search Available Trips';

  String get journeySearchInformation => isFrench
      ? 'Les horaires et tarifs disponibles seront affichés après la recherche.'
      : 'Available schedules and fares will be displayed after the search.';

  // ==================================================
  // TRIP RESULTS
  // ==================================================

  String get availableTrips =>
      isFrench ? 'Voyages disponibles' : 'Available Trips';

  String get from => isFrench ? 'DÉPART' : 'FROM';
  String get to => isFrench ? 'ARRIVÉE' : 'TO';

  String passengerCount(int count) {
    if (isFrench) {
      return '$count passager${count > 1 ? 's' : ''}';
    }

    return '$count ${count == 1 ? 'passenger' : 'passengers'}';
  }

  String luggageCount(int count) {
    return isFrench ? '$count bagage${count > 1 ? 's' : ''}' : '$count luggage';
  }

  String seatsLeft(int count) {
    if (isFrench) {
      return '$count place${count > 1 ? 's' : ''} '
          'disponible${count > 1 ? 's' : ''}';
    }

    return '$count ${count == 1 ? 'seat' : 'seats'} left';
  }

  String get departure => isFrench ? 'Départ' : 'Departure';
  String get arrival => isFrench ? 'Arrivée' : 'Arrival';

  String get interurbanFare =>
      isFrench ? 'Tarif interurbain' : 'Interurban fare';

  String get perPassenger => isFrench ? 'par passager' : 'per passenger';

  String get insufficientSeats =>
      isFrench ? 'Places insuffisantes' : 'Insufficient seats';

  String get tripResultsDemoInformation => isFrench
      ? 'Les voyages affichés sont des données de démonstration. Les horaires, tarifs et places disponibles réels seront fournis par le backend de l’agence.'
      : 'The trips shown are demonstration data. Real schedules, fares and available seats will be provided by the agency backend.';

  // ==================================================
  // BOOKING REVIEW
  // ==================================================

  String get reviewBooking =>
      isFrench ? 'Vérifier la réservation' : 'Review Booking';

  String get agencyToAgencyTransport =>
      isFrench ? 'Transport d’agence à agence' : 'Agency-to-agency transport';

  String get taxiInterurbanTaxi =>
      isFrench ? 'Taxi + Interurbain + Taxi' : 'Taxi + Interurban + Taxi';

  String get journey => isFrench ? 'Trajet' : 'Journey';
  String get agency => isFrench ? 'Agence' : 'Agency';
  String get route => isFrench ? 'Itinéraire' : 'Route';

  String get selectedTrip => isFrench ? 'Voyage sélectionné' : 'Selected Trip';

  String get travelClass => isFrench ? 'Classe' : 'Class';
  String get duration => isFrench ? 'Durée' : 'Duration';

  String get travelInformation =>
      isFrench ? 'Informations de voyage' : 'Travel Information';

  String get luggageItems => isFrench ? 'Nombre de bagages' : 'Luggage Items';

  String get doorToDoorDetails =>
      isFrench ? 'Détails du porte-à-porte' : 'Door-to-Door Details';

  String get interurbanTrip =>
      isFrench ? 'Voyage interurbain' : 'Interurban Trip';

  String get priceSummary => isFrench ? 'Résumé du prix' : 'Price Summary';

  String interurbanFareForPassengers(int count) {
    return isFrench ? 'Tarif interurbain × $count' : 'Interurban fare × $count';
  }

  String get pickupTaxiFareLabel =>
      isFrench ? 'Taxi de prise en charge' : 'Pickup taxi';

  String get destinationTaxiFareLabel =>
      isFrench ? 'Taxi vers la destination' : 'Destination taxi';

  String get total => 'Total';

  String get estimatedTaxiFares =>
      isFrench ? 'Tarifs de taxi estimés' : 'Estimated taxi fares';

  String get amountPayable =>
      isFrench ? 'Montant à payer' : 'Amount payable';

  String get temporaryTaxiEstimate => isFrench
      ? 'Les tarifs de taxi de prise en charge et vers la destination sont des estimations pour le premier et le dernier kilomètre. Ils sont payés directement au chauffeur et ne font pas partie du montant débité dans l’application.'
      : 'Pickup and destination taxi fares are estimates for the first and last mile. They are paid directly to the driver and are not part of the amount charged in the application.';

  String get continueToPayment =>
      isFrench ? 'Continuer vers le paiement' : 'Continue to Payment';

  // ==================================================
  // PAYMENT
  // ==================================================

  String get payment => isFrench ? 'Paiement' : 'Payment';

  String get amountToPay => isFrench ? 'Montant à payer' : 'Amount to Pay';

  String get selectPaymentMethod =>
      isFrench ? 'Sélectionnez un moyen de paiement' : 'Select Payment Method';

  String get mtnMobileMoney => 'MTN Mobile Money';

  String get mtnMobileMoneyDescription => isFrench
      ? 'Payez avec votre compte MTN MoMo'
      : 'Pay using your MTN MoMo account';

  String get orangeMoney => 'Orange Money';

  String get orangeMoneyDescription => isFrench
      ? 'Payez avec votre compte Orange Money'
      : 'Pay using your Orange Money account';

  String get paymentPhoneNumber =>
      isFrench ? 'Numéro de téléphone de paiement' : 'Payment Phone Number';

  String get paymentPhoneHint => '6XX XXX XXX';

  String get selectPaymentMethodError => isFrench
      ? 'Veuillez sélectionner un moyen de paiement.'
      : 'Please select a payment method.';

  String get paymentPhoneRequired => isFrench
      ? 'Veuillez entrer le numéro de téléphone de paiement.'
      : 'Please enter the payment phone number.';

  String get invalidPhoneNumber => isFrench
      ? 'Veuillez entrer un numéro de téléphone valide.'
      : 'Please enter a valid phone number.';

  String get prototypePaymentInformation => isFrench
      ? 'Pour le prototype actuel, le paiement est simulé. Aucun transfert réel d’argent ne sera effectué.'
      : 'For the current prototype, payment is simulated. No real money will be transferred.';

  String get paymentSecurityInformation => isFrench
      ? 'Le paiement réel et la vérification des transactions seront gérés ultérieurement par le backend et le fournisseur de paiement.'
      : 'Real payment and transaction verification will later be handled by the backend and payment provider.';

  String payAmount(String amount) {
    return isFrench ? 'Payer $amount FCFA' : 'Pay $amount FCFA';
  }

  String get processingPayment =>
      isFrench ? 'Traitement du paiement...' : 'Processing Payment...';

  // ==================================================
  // BOOKING CONFIRMATION
  // ==================================================

  String get paymentSuccessful =>
      isFrench ? 'Paiement réussi' : 'Payment Successful';

  String get paymentSuccessfulDescription => isFrench
      ? 'Votre paiement a été traité avec succès.'
      : 'Your payment has been successfully processed.';

  String get paymentMethod => isFrench ? 'Moyen de paiement' : 'Payment Method';

  String get amountPaid => isFrench ? 'Montant payé' : 'Amount Paid';

  String get digitalTicketReferenceInformation => isFrench
      ? 'Votre billet numérique contiendra les références officielles de réservation et de billet générées par easyGO.'
      : 'Your digital ticket will contain the official booking and ticket references generated by easyGO.';

  String get viewDigitalTicket =>
      isFrench ? 'Voir le billet numérique' : 'View Digital Ticket';

  String get returnToHome => isFrench ? 'Retour à l’accueil' : 'Return to Home';

  String get bookingConfirmed =>
      isFrench ? 'Réservation confirmée' : 'Booking Confirmed';

  // ==================================================
  // DIGITAL TICKET
  // ==================================================

  String get digitalTicket => isFrench ? 'Billet numérique' : 'Digital Ticket';

  String get doorToDoorTicket =>
      isFrench ? 'Billet porte-à-porte' : 'Door-to-Door Ticket';

  String get interurbanTicket =>
      isFrench ? 'Billet interurbain' : 'Interurban Ticket';

  String get paid => isFrench ? 'PAYÉ' : 'PAID';

  String get date => isFrench ? 'DATE' : 'DATE';

  String get classLabel => isFrench ? 'CLASSE' : 'CLASS';

  String get passengersLabel => isFrench ? 'PASSAGERS' : 'PASSENGERS';

  String get luggageLabel => isFrench ? 'BAGAGES' : 'LUGGAGE';

  String get bookingReference =>
      isFrench ? 'Référence de réservation' : 'Booking Reference';

  String get ticketReference =>
      isFrench ? 'Référence du billet' : 'Ticket Reference';

  String get presentTicketForVerification => isFrench
      ? 'Présentez ce billet pour vérification'
      : 'Present this ticket for verification';

  String paidVia(String method) {
    return isFrench ? 'Payé via $method' : 'Paid via $method';
  }

  String get pickup => isFrench ? 'Prise en charge' : 'Pickup';

  String get interurban => isFrench ? 'Interurbain' : 'Interurban';

  String get pickupLocationFallback =>
      isFrench ? 'Lieu de prise en charge' : 'Pickup location';

  String get finalDestinationFallback =>
      isFrench ? 'Destination finale' : 'Final destination';

  String get taxiAssignmentInformation => isFrench
      ? 'Les informations du taxi apparaîtront lorsque le fournisseur externe de taxi aura affecté un chauffeur.'
      : 'Taxi assignment information will appear when the external taxi provider assigns a driver.';

  String get importantTicketInformation => isFrench
      ? 'Conservez votre billet numérique disponible pendant le voyage. Le personnel de l’agence peut le vérifier avant l’embarquement.'
      : 'Keep your digital ticket available during your journey. Agency staff may verify it before boarding.';

  String get downloadTicket =>
      isFrench ? 'Télécharger le billet' : 'Download Ticket';

  String get ticketDownloadPending => isFrench
      ? 'Le téléchargement du billet sera connecté lors de l’intégration de la génération PDF.'
      : 'Ticket download will be connected when PDF generation is integrated.';

  String get verifyTicket =>
      isFrench ? 'Vérifier un billet' : 'Verify Ticket';

  String get verifyTicketDescription => isFrench
      ? 'Saisissez la référence du billet présenté par le voyageur pour confirmer qu’il est valable. Seuls les billets de votre propre agence peuvent être vérifiés.'
      : 'Enter the reference on the ticket a traveller presents to confirm it is valid. Only tickets for your own agency can be verified.';

  String get ticketVerificationDescription => isFrench
      ? 'Contrôler un billet à l’embarquement'
      : 'Check a ticket at boarding';

  // ==================================================
  // TRACKING HOME
  // ==================================================

  String get trackingServices =>
      isFrench ? 'Services de suivi' : 'Tracking Services';

  String get chooseTrackingService => isFrench
      ? 'Choisissez ce que vous souhaitez suivre ou gérer.'
      : 'Choose what you want to track or manage.';

  String get trackYourItems =>
      isFrench ? 'Suivez vos articles' : 'Track Your Items';

  String get trackYourItemsDescription => isFrench
      ? 'Suivez l’état opérationnel de vos bagages ou colis.'
      : 'Follow the operational status of your luggage or parcel.';

  String get trackByReference =>
      isFrench ? 'Suivre par référence' : 'Track by Reference';

  String get trackByReferenceDescription => isFrench
      ? 'Entrez une référence de suivi de bagage ou de colis pour consulter son état actuel.'
      : 'Enter a luggage or parcel tracking reference to view its current status.';

  String get trackingReference =>
      isFrench ? 'Référence de suivi' : 'Tracking Reference';

  String get trackingReferenceExample => isFrench
      ? 'Exemple : LUG-MUGZCQ0H-20LB45'
      : 'Example: LUG-MUGZCQ0H-20LB45';

  String get trackingReferenceRequired => isFrench
      ? 'Veuillez entrer une référence de suivi.'
      : 'Please enter a tracking reference.';

  String get trackItem => isFrench ? 'Suivre l’article' : 'Track Item';

  String get travelerLuggage =>
      isFrench ? 'Bagages du voyageur' : 'Traveler Luggage';

  String get travelerLuggageDescription => isFrench
      ? 'Consultez et suivez les bagages associés à vos réservations de voyage.'
      : 'View and track luggage linked to your travel bookings.';

  String get linkedToBooking =>
      isFrench ? 'Lié à la réservation' : 'Linked to Booking';

  String get independentParcel =>
      isFrench ? 'Colis indépendant' : 'Independent Parcel';

  String get independentParcelDescription => isFrench
      ? 'Envoyez ou suivez des colis sans effectuer de voyage.'
      : 'Send or track parcels without travelling.';

  String get parcelService => isFrench ? 'Service de colis' : 'Parcel Service';

  String get howTrackingWorks =>
      isFrench ? 'Comment fonctionne le suivi' : 'How tracking works';

  String get trackingExplanation => isFrench
      ? 'L’indicateur de progression représente les étapes opérationnelles du transport : Enregistré, Reçu par l’agence, Chargé, En transit, Arrivé, Prêt pour le retrait et Livré. Il ne représente pas le déplacement GPS en temps réel.'
      : 'The progress indicator represents operational transport stages such as Registered, Received by Agency, Loaded, In Transit, Arrived, Ready for Collection and Delivered. It does not represent real-time GPS movement.';

  // ==================================================
  // TRACKING DETAILS
  // ==================================================

  String get trackingDetails =>
      isFrench ? 'Détails du suivi' : 'Tracking Details';

  String get journeyProgress =>
      isFrench ? 'Progression du transport' : 'Journey Progress';

  String get progress => isFrench ? 'PROGRESSION' : 'PROGRESS';

  String get operationalProgressDescription => isFrench
      ? 'La progression représente l’état opérationnel du suivi de l’article.'
      : 'Progress represents the operational tracking status of the item.';

  String get transportRoute =>
      isFrench ? 'Itinéraire de transport' : 'Transport Route';

  String get trackingTimeline =>
      isFrench ? 'Chronologie du suivi' : 'Tracking Timeline';

  String get currentStatus => isFrench ? 'État actuel' : 'Current status';

  String get trackingUpdateNotice => isFrench
      ? 'Les informations de suivi sont mises à jour lorsque l’agence de transport responsable enregistre un nouvel état opérationnel.'
      : 'Tracking information is updated when the responsible transport agency records a new operational status.';

  String trackingStatusLabel(String status) {
    switch (status) {
      case 'Registered':
        return isFrench ? 'Enregistré' : 'Registered';

      case 'Received by Agency':
        return isFrench ? 'Reçu par l’agence' : 'Received by Agency';

      case 'Loaded':
        return isFrench ? 'Chargé' : 'Loaded';

      case 'In Transit':
        return isFrench ? 'En transit' : 'In Transit';

      case 'Arrived':
        return isFrench ? 'Arrivé' : 'Arrived';

      case 'Ready for Collection':
        return isFrench ? 'Prêt pour le retrait' : 'Ready for Collection';

      case 'Delivered':
        return isFrench ? 'Livré' : 'Delivered';

      // Backend status values.
      case 'REGISTERED':
        return isFrench ? 'Enregistré' : 'Registered';

      case 'RECEIVED_AT_AGENCY':
        return isFrench ? 'Reçu par l’agence' : 'Received by Agency';

      case 'RECEIVED_AT_ORIGIN_AGENCY':
        return isFrench
            ? 'Reçu à l’agence de départ'
            : 'Received at Origin Agency';

      case 'LOADED':
        return isFrench ? 'Chargé' : 'Loaded';

      case 'IN_TRANSIT':
        return isFrench ? 'En transit' : 'In Transit';

      case 'ARRIVED_AT_DESTINATION_AGENCY':
        return isFrench
            ? 'Arrivé à l’agence d’arrivée'
            : 'Arrived at Destination Agency';

      case 'READY_FOR_COLLECTION':
        return isFrench ? 'Prêt pour le retrait' : 'Ready for Collection';

      case 'COLLECTED':
        return isFrench ? 'Retiré' : 'Collected';

      case 'DELIVERED':
        return isFrench ? 'Livré' : 'Delivered';

      case 'LOST':
        return isFrench ? 'Perdu' : 'Lost';

      case 'CANCELLED':
        return isFrench ? 'Annulé' : 'Cancelled';

      default:
        return status;
    }
  }

  // ==================================================
  // TRAVELER LUGGAGE
  // ==================================================

  String get travelLuggage => isFrench ? 'Bagages de voyage' : 'Travel Luggage';

  String get travelLuggageDescription => isFrench
      ? 'Consultez et suivez les bagages enregistrés avec vos réservations de voyage.'
      : 'View and track luggage registered with your travel bookings.';

  String get myLuggage => isFrench ? 'Mes bagages' : 'My Luggage';

  String luggageItemCount(int count) {
    if (isFrench) {
      return '$count bagage${count > 1 ? 's' : ''}';
    }

    return '$count ${count == 1 ? 'item' : 'items'}';
  }

  String get booking => isFrench ? 'Réservation' : 'Booking';

  String get weight => isFrench ? 'Poids' : 'Weight';

  String get trackLuggage => isFrench ? 'Suivre le bagage' : 'Track Luggage';

  String get travelerLuggageInformation => isFrench
      ? 'Les bagages du voyageur sont liés à une réservation de voyage confirmée. Leur état opérationnel est mis à jour par l’agence de transport responsable.'
      : 'Traveler luggage is linked to a confirmed travel booking. Its operational status is updated by the responsible transport agency.';

  String luggageDescriptionLabel(String description) {
    switch (description) {
      case 'Large black suitcase':
        return isFrench ? 'Grande valise noire' : 'Large black suitcase';

      case 'Medium blue travel bag':
        return isFrench ? 'Sac de voyage bleu moyen' : 'Medium blue travel bag';

      default:
        return description;
    }
  }

  // ==================================================
  // INDEPENDENT PARCEL
  // ==================================================

  String get interurbanParcelService =>
      isFrench ? 'Service de colis interurbain' : 'Interurban Parcel Service';

  String get interurbanParcelServiceDescription => isFrench
      ? 'Envoyez et suivez des colis entre les villes sans avoir à voyager avec eux.'
      : 'Send and track parcels between cities without travelling with them.';

  String get sendNewParcel =>
      isFrench ? 'Envoyer un nouveau colis' : 'Send a New Parcel';

  String get sendNewParcelDescription => isFrench
      ? 'Créez une nouvelle expédition de colis interurbain.'
      : 'Create a new interurban parcel shipment.';

  String get myParcels => isFrench ? 'Mes colis' : 'My Parcels';

  String get myParcelsDescription => isFrench
      ? 'Consultez vos expéditions de colis et suivez leur état actuel.'
      : 'View your parcel shipments and track their current status.';

  String get independentParcelInformation => isFrench
      ? 'Le service de colis indépendant permet d’envoyer un colis entre deux villes sans réservation de voyage. Chaque colis reçoit sa propre référence de suivi.'
      : 'The independent parcel service allows a parcel to be sent between two cities without a travel booking. Each parcel receives its own tracking reference.';

  // ==================================================
  // CREATE PARCEL
  // ==================================================

  String get sendParcel => isFrench ? 'Envoyer un colis' : 'Send Parcel';

  String get interurbanParcelDelivery => isFrench
      ? 'Livraison interurbaine de colis'
      : 'Interurban Parcel Delivery';

  String get interurbanParcelDeliveryDescription => isFrench
      ? 'Saisissez les informations du destinataire, de l’itinéraire et du colis pour préparer votre expédition.'
      : 'Enter the recipient, route and parcel information to prepare your shipment.';

  String get recipientInformation =>
      isFrench ? 'Informations du destinataire' : 'Recipient Information';

  String get recipientName =>
      isFrench ? 'Nom du destinataire' : 'Recipient Name';

  String get recipientPhone =>
      isFrench ? 'Téléphone du destinataire' : 'Recipient Phone';

  String get recipientNameRequired => isFrench
      ? 'Veuillez entrer le nom du destinataire.'
      : 'Please enter the recipient name.';

  String get recipientPhoneRequired => isFrench
      ? 'Veuillez entrer le numéro de téléphone du destinataire.'
      : 'Please enter the recipient phone number.';

  String get validPhoneNumberRequired => isFrench
      ? 'Veuillez entrer un numéro de téléphone valide.'
      : 'Please enter a valid phone number.';

  String get selectParcelCitiesError => isFrench
      ? 'Veuillez sélectionner les villes de départ et de destination.'
      : 'Please select the departure and destination cities.';

  String get differentParcelCitiesError => isFrench
      ? 'Les villes de départ et de destination doivent être différentes.'
      : 'Departure and destination cities must be different.';

  String get parcelInformation =>
      isFrench ? 'Informations du colis' : 'Parcel Information';

  String get parcelDescription =>
      isFrench ? 'Description du colis' : 'Parcel Description';

  String get parcelDescriptionHint => isFrench
      ? 'Exemple : vêtements dans une boîte moyenne'
      : 'Example: clothes in a medium box';

  String get parcelDescriptionRequired => isFrench
      ? 'Veuillez entrer une description du colis.'
      : 'Please enter a parcel description.';

  String get approximateWeight =>
      isFrench ? 'Poids approximatif (kg)' : 'Approximate Weight (kg)';

  String get parcelWeightRequired => isFrench
      ? 'Veuillez entrer le poids du colis.'
      : 'Please enter the parcel weight.';

  String get validParcelWeightRequired => isFrench
      ? 'Veuillez entrer un poids valide supérieur à 0.'
      : 'Please enter a valid weight greater than 0.';

  String get parcelReceptionNotice => isFrench
      ? 'Après la création et le paiement, le colis reste au statut Enregistré jusqu’à sa remise physique et sa réception par l’agence.'
      : 'After creation and payment, the parcel remains Registered until it is physically handed over to and received by the agency.';

  String get continueToReview =>
      isFrench ? 'Continuer vers la vérification' : 'Continue to Review';

  // ==================================================
  // PARCEL REVIEW
  // ==================================================

  String get reviewParcel => isFrench ? 'Vérifier le colis' : 'Review Parcel';

  String get parcelRoute => isFrench ? 'Itinéraire du colis' : 'Parcel Route';

  String get name => isFrench ? 'Nom' : 'Name';

  String get description => isFrench ? 'Description' : 'Description';

  String get parcelPricingNotice => isFrench
      ? 'Le tarif final du transport du colis doit être calculé et validé par le backend easyGO selon l’agence sélectionnée, l’itinéraire, le poids du colis et les règles tarifaires applicables.'
      : 'The final parcel transport fee must be calculated and validated by the easyGO backend using the selected agency, route, parcel weight and applicable pricing rules.';

  String get continueToParcelService =>
      isFrench ? 'Choisir l’agence et le service' : 'Choose Agency & Service';

  // ==================================================
  // PARCEL SERVICE SELECTION
  // ==================================================

  String get parcelServices =>
      isFrench ? 'Services de colis' : 'Parcel Services';

  String get parcelRequest => isFrench ? 'Demande de colis' : 'Parcel Request';

  String get availableTransportServices => isFrench
      ? 'Services de transport disponibles'
      : 'Available Transport Services';

  String get selectParcelAgencyDescription => isFrench
      ? 'Sélectionnez l’agence qui transportera votre colis.'
      : 'Select the agency that will transport your parcel.';

  String get selectParcelTransportServiceError => isFrench
      ? 'Veuillez sélectionner un service de transport de colis.'
      : 'Please select a parcel transport service.';

  String get parcelFee => isFrench ? 'Frais du colis' : 'Parcel Fee';

  String parcelDurationLabel(String duration) {
    switch (duration) {
      case 'Same day':
        return isFrench ? 'Le jour même' : 'Same day';

      case 'Within 24 hours':
        return isFrench ? 'Sous 24 heures' : 'Within 24 hours';

      default:
        return duration;
    }
  }

  // ==================================================
  // PARCEL PAYMENT
  // ==================================================

  String get parcelPayment => isFrench ? 'Paiement du colis' : 'Parcel Payment';

  String get enterPaymentPhoneNumber => isFrench
      ? 'Veuillez entrer le numéro de téléphone de paiement.'
      : 'Enter the payment phone number.';

  String get enterValidPaymentPhoneNumber => isFrench
      ? 'Veuillez entrer un numéro de téléphone valide.'
      : 'Enter a valid phone number.';

  String payParcelAmount(String amount) {
    return isFrench ? 'Payer $amount FCFA' : 'Pay $amount FCFA';
  }

  // ==================================================
  // PARCEL CONFIRMATION
  // ==================================================

  String get shipmentConfirmation =>
      isFrench ? 'Confirmation de l’expédition' : 'Shipment Confirmation';

  String get parcelShipmentCreated =>
      isFrench ? 'Expédition du colis créée' : 'Parcel Shipment Created';

  String get parcelShipmentCreatedDescription => isFrench
      ? 'Votre expédition de colis a été enregistrée en mode prototype.'
      : 'Your parcel shipment has been registered in prototype mode.';

  String get trackingReferenceLabel =>
      isFrench ? 'RÉFÉRENCE DE SUIVI' : 'TRACKING REFERENCE';

  String get demoTrackingReferenceNotice => isFrench
      ? 'Référence de démonstration — les références de production seront générées par le backend.'
      : 'Demo reference — production references will be generated by the backend.';

  String get recipient => isFrench ? 'Destinataire' : 'Recipient';

  String get parcel => isFrench ? 'Colis' : 'Parcel';

  String get amount => isFrench ? 'Montant' : 'Amount';

  String get trackParcel => isFrench ? 'Suivre le colis' : 'Track Parcel';

  // ==================================================
  // MY PARCELS
  // ==================================================

  String get myParcelShipments =>
      isFrench ? 'Mes expéditions de colis' : 'My Parcel Shipments';

  String get myParcelShipmentsDescription => isFrench
      ? 'Consultez vos expéditions interurbaines de colis et leur état de suivi actuel.'
      : 'View your interurban parcel shipments and their current tracking status.';

  String get parcelShipments =>
      isFrench ? 'Expéditions de colis' : 'Parcel Shipments';

  String parcelShipmentCount(int count) {
    if (isFrench) {
      return '$count colis';
    }

    return '$count ${count == 1 ? 'parcel' : 'parcels'}';
  }

  // ==================================================
  // CLIENT TRIPS
  // ==================================================

  String get myTrips => isFrench ? 'Mes voyages' : 'My Trips';
  String get bookingDetails =>
      isFrench ? 'Détails de la réservation' : 'Booking Details';
  String get upcoming => isFrench ? 'À venir' : 'Upcoming';
  String get completed => isFrench ? 'Terminé' : 'Completed';
  String get cancelled => isFrench ? 'Annulé' : 'Cancelled';

  String tripStatusLabel(String status) {
    switch (status) {
      case 'Upcoming':
        return upcoming;
      case 'Completed':
        return completed;
      case 'Cancelled':
        return cancelled;
      default:
        return status;
    }
  }

  String get bookingMode => isFrench ? 'Mode de réservation' : 'Booking Mode';

  String bookingModeLabel(String bookingMode) {
    switch (bookingMode) {
      case 'Door-to-Door':
      case 'door_to_door':
        return doorToDoor;
      case 'Interurban Only':
      case 'interurban_only':
        return interurbanOnly;
      default:
        return bookingMode;
    }
  }

  String get noUpcomingTrips =>
      isFrench ? 'Aucun voyage à venir' : 'No Upcoming Trips';
  String get noCompletedTrips =>
      isFrench ? 'Aucun voyage terminé' : 'No Completed Trips';
  String get noCancelledTrips =>
      isFrench ? 'Aucun voyage annulé' : 'No Cancelled Trips';

  String emptyTripsTitle(String status) {
    switch (status) {
      case 'Upcoming':
        return noUpcomingTrips;
      case 'Completed':
        return noCompletedTrips;
      case 'Cancelled':
        return noCancelledTrips;
      default:
        return isFrench ? 'Aucun voyage' : 'No Trips';
    }
  }

  String emptyTripsDescription(String status) {
    switch (status) {
      case 'Upcoming':
        return isFrench
            ? 'Vos prochains voyages apparaîtront ici.'
            : 'Your upcoming trips will appear here.';
      case 'Completed':
        return isFrench
            ? 'Vos voyages terminés apparaîtront ici.'
            : 'Your completed trips will appear here.';
      case 'Cancelled':
        return isFrench
            ? 'Vos voyages annulés apparaîtront ici.'
            : 'Your cancelled trips will appear here.';
      default:
        return isFrench
            ? 'Vos voyages apparaîtront ici.'
            : 'Your trips will appear here.';
    }
  }

  String get amountLabel => isFrench ? 'Montant' : 'Amount';
  String get bookingReferenceLabel =>
      isFrench ? 'RÉFÉRENCE DE RÉSERVATION' : 'BOOKING REFERENCE';
  String get departureLabel => isFrench ? 'DÉPART' : 'DEPARTURE';
  String get arrivalLabel => isFrench ? 'ARRIVÉE' : 'ARRIVAL';

  String get paymentInformation =>
      isFrench ? 'Informations de paiement' : 'Payment Information';

  String get paymentStatus =>
      isFrench ? 'Statut du paiement' : 'Payment Status';

  String get scheduled => isFrench ? 'Planifié' : 'Scheduled';
  String get pendingAssignment =>
      isFrench ? 'Affectation en attente' : 'Pending Assignment';

  String journeyStageStatusLabel(String status) {
    switch (status) {
      case 'Scheduled':
        return scheduled;
      case 'Pending Assignment':
        return pendingAssignment;
      case 'Upcoming':
      case 'Completed':
      case 'Cancelled':
        return tripStatusLabel(status);
      default:
        return status;
    }
  }

  String get pickupTaxiAssignmentPending => isFrench
      ? 'Les informations du chauffeur apparaîtront dès qu’un taxi sera affecté.'
      : 'Driver assignment will appear when available.';

  String get destinationTaxiAssignmentPending => isFrench
      ? 'Les informations du chauffeur apparaîtront à l’approche de l’arrivée.'
      : 'Driver assignment will appear near arrival.';

  String get bookingLuggage =>
      isFrench ? 'Bagages de la réservation' : 'Booking Luggage';

  String get luggageForThisBooking =>
      isFrench ? 'Bagages de cette réservation' : 'Luggage for this Booking';

  String get registeredLuggage =>
      isFrench ? 'Bagages enregistrés' : 'Registered Luggage';

  String get noLuggage => isFrench ? 'Aucun bagage' : 'No Luggage';

  String noLuggageForBooking(String bookingReference) {
    return isFrench
        ? 'Aucun bagage n’est enregistré pour $bookingReference.'
        : 'No luggage is registered for $bookingReference.';
  }

  String get bookingLuggageInformation => isFrench
      ? 'Les bagages sont liés à cette réservation. Les états opérationnels de suivi sont mis à jour par l’agence de transport au fur et à mesure du voyage.'
      : 'Luggage is linked to this booking. Operational tracking statuses are updated by the transport agency as the luggage moves through the journey.';

  String get travelerSuitcase =>
      isFrench ? 'Valise du voyageur' : 'Traveler suitcase';

  String luggageItemDescriptionLabel(String description) {
    switch (description) {
      case 'Traveler suitcase':
        return travelerSuitcase;
      case 'Medium blue travel bag':
      case 'Large black suitcase':
        return luggageDescriptionLabel(description);
      default:
        return description;
    }
  }

  // ==================================================
  // PROFILE
  // ==================================================

  String get account => isFrench ? 'Compte' : 'Account';

  String get personalInformation =>
      isFrench ? 'Informations personnelles' : 'Personal Information';

  String get personalInformationSubtitle => isFrench
      ? 'Consultez et modifiez les informations de votre compte'
      : 'View and update your account information';

  String get notificationsSubtitle => isFrench
      ? 'Consultez les notifications de voyage et de suivi'
      : 'View travel and tracking notifications';

  String get settingsSubtitle => isFrench
      ? 'Langue, apparence et préférences de l’application'
      : 'Language, appearance and application preferences';

  String get support => isFrench ? 'Assistance' : 'Support';

  String get helpSupport => isFrench ? 'Aide et assistance' : 'Help & Support';

  String get helpSupportSubtitle => isFrench
      ? 'Obtenez de l’aide pour utiliser easyGO'
      : 'Get assistance using easyGO';

  String get aboutEasyGo => isFrench ? 'À propos de easyGO' : 'About easyGO';

  String get aboutEasyGoSubtitle => isFrench
      ? 'Informations sur l’application et le projet'
      : 'Application and project information';

  String get logoutSubtitle => isFrench
      ? 'Déconnectez-vous de votre compte easyGO'
      : 'Sign out of your easyGO account';

  String get logoutQuestion => isFrench
      ? 'Voulez-vous vraiment vous déconnecter de easyGO ?'
      : 'Are you sure you want to logout from easyGO?';

  String get profileUpdated => isFrench
      ? 'Les informations du profil ont été mises à jour.'
      : 'Profile information updated.';

  String get aboutDescription => isFrench
      ? 'easyGO est un système de gestion des voyages interurbains porte-à-porte et de suivi des bagages, conçu pour accompagner les voyageurs interurbains et les expéditeurs de colis.'
      : 'easyGO is an Interurban Door-to-Door Travel Management and Luggage Tracking System designed to support interurban travelers and parcel senders.';

  String get version => 'Version 1.0.0';

  // ==================================================
  // SETTINGS
  // ==================================================

  String get preferences => isFrench ? 'Préférences' : 'Preferences';

  String get settingsDescription => isFrench
      ? 'Personnalisez votre expérience easyGO.'
      : 'Personalize your easyGO experience.';

  String get appearance => isFrench ? 'Apparence' : 'Appearance';

  String get appearanceDescription => isFrench
      ? 'Choisissez l’apparence de easyGO sur cet appareil.'
      : 'Choose how easyGO looks on this device.';

  String get system => isFrench ? 'Système' : 'System';

  String get systemDescription => isFrench
      ? 'Suivre l’apparence de votre appareil'
      : 'Follow your device appearance';

  String get light => isFrench ? 'Clair' : 'Light';

  String get lightDescription => isFrench
      ? 'Utiliser l’interface claire de easyGO'
      : 'Use the light easyGO interface';

  String get dark => isFrench ? 'Sombre' : 'Dark';

  String get darkDescription => isFrench
      ? 'Utiliser l’interface sombre de easyGO'
      : 'Use the dark easyGO interface';

  String get language => isFrench ? 'Langue' : 'Language';

  String get languageDescription => isFrench
      ? 'Sélectionnez la langue de l’application.'
      : 'Select your preferred application language.';

  String get english => isFrench ? 'Anglais' : 'English';
  String get french => isFrench ? 'Français' : 'French';

  String get settingsInformation => isFrench
      ? 'Les modifications de l’apparence et de la langue sont appliquées immédiatement.'
      : 'Appearance and language changes are applied immediately.';

  // ==================================================
  // AGENCY PORTAL
  // ==================================================

  String get agencyDashboard =>
      isFrench ? 'Tableau de bord agence' : 'Agency Dashboard';

  String get operations => isFrench ? 'Opérations' : 'Operations';

  String get messages => isFrench ? 'Messages' : 'Messages';

  String get bookings => isFrench ? 'Réservations' : 'Bookings';

  String get parcels => isFrench ? 'Colis' : 'Parcels';

  String get createTrip => isFrench ? 'Créer un voyage' : 'Create Trip';

  String get viewTrips => isFrench ? 'Voir les voyages' : 'View Trips';

  String get viewBookings =>
      isFrench ? 'Voir les réservations' : 'View Bookings';

  String get manageLuggage => isFrench ? 'Gérer les bagages' : 'Manage Luggage';

  String get clientMessages =>
      isFrench ? 'Messages des clients' : 'Client Messages';

  String get tripManagement =>
      isFrench ? 'Gestion des voyages' : 'Trip Management';

  String get bookingManagement =>
      isFrench ? 'Gestion des réservations' : 'Booking Management';

  String get luggageManagement =>
      isFrench ? 'Gestion des bagages' : 'Luggage Management';

  String get parcelManagement =>
      isFrench ? 'Gestion des colis' : 'Parcel Management';

  String get messageManagement =>
      isFrench ? 'Gestion des messages' : 'Message Management';

  String get agencyProfile =>
      isFrench ? 'Profil de l’agence' : 'Agency Profile';

  String get editProfile => isFrench ? 'Modifier le profil' : 'Edit Profile';

  String get editAgencyProfile =>
      isFrench ? 'Modifier le profil de l’agence' : 'Edit Agency Profile';

  String get editAgencyInformation => isFrench
      ? 'Modifier les informations de l’agence'
      : 'Edit Agency Information';

  String get updateAgencyInformation => isFrench
      ? 'Mettre à jour les informations de l’agence'
      : 'Update Agency Information';

  String get updateAgencyInformationDescription => isFrench
      ? 'Modifiez les informations publiques et les coordonnées de votre agence.'
      : 'Modify your agency public information and contact details.';

  String get agencyName => isFrench ? 'Nom de l’agence' : 'Agency Name';

  String get agencyDescription =>
      isFrench ? 'Description de l’agence' : 'Agency Description';

  String get generalInformation =>
      isFrench ? 'Informations générales' : 'General Information';

  String get contactInformation =>
      isFrench ? 'Coordonnées' : 'Contact Information';

  String get locationInformation =>
      isFrench ? 'Informations de localisation' : 'Location Information';

  String get emailAddress => isFrench ? 'Adresse e-mail' : 'Email Address';

  String get phoneNumber => isFrench ? 'Numéro de téléphone' : 'Phone Number';

  String get headOffice => isFrench ? 'Siège principal' : 'Head Office';

  String get publicAgencyInformation => isFrench
      ? 'Informations publiques de l’agence'
      : 'Public Agency Information';

  String get publicAgencyInformationDescription => isFrench
      ? 'Ces informations permettent aux voyageurs d’identifier et de consulter les détails de l’agence dans easyGO.'
      : 'This information helps travelers identify and view the agency details in easyGO.';

  String get publicAgencyVisibilityNotice => isFrench
      ? 'Les informations validées de l’agence pourront être affichées aux clients dans la recherche, les détails de l’agence et les services associés.'
      : 'Validated agency information can be displayed to clients in search, agency details and related services.';

  String get profileManagement =>
      isFrench ? 'Gestion du profil' : 'Profile Management';

  String get profileManagementNotice => isFrench
      ? 'Seul un membre du personnel de cette agence peut modifier sa fiche. Le backend résout l’agence à partir de l’appartenance du compte connecté, et non à partir de ce qui est envoyé par l’application.'
      : 'Only a staff member of this agency can edit its record. The backend resolves the agency from the signed-in account’s membership rather than from anything the app sends.';

  String get saveChanges =>
      isFrench ? 'Enregistrer les modifications' : 'Save Changes';

  String get savingChanges =>
      isFrench ? 'Enregistrement...' : 'Saving Changes...';

  String get requiredField =>
      isFrench ? 'Ce champ est obligatoire.' : 'This field is required.';

  String get invalidEmailAddress => isFrench
      ? 'Saisissez une adresse e-mail valide.'
      : 'Enter a valid email address.';

  String get agencyProfileBackendNotice => isFrench
      ? 'Les modifications sont enregistrées directement sur la fiche de l’agence. Chaque adresse appartient à une succursale et se gère donc au niveau de la succursale.'
      : 'Changes are saved straight to the agency record. Each address belongs to a branch, so addresses are managed per branch.';

  String get continueLabel => isFrench ? 'Continuer' : 'Continue';

  String get confirmed => isFrench ? 'Confirmée' : 'Confirmed';

  String get completedStatus => isFrench ? 'Terminée' : 'Completed';

  String get cancelledStatus => isFrench ? 'Annulée' : 'Cancelled';

  String get scheduledStatus => isFrench ? 'Programmé' : 'Scheduled';

  String get active => isFrench ? 'Actif' : 'Active';

  String get deliveredStatus => isFrench ? 'Livré' : 'Delivered';

  String get clientConversations =>
      isFrench ? 'Conversations clients' : 'Client Conversations';

  String get noConversationsFound =>
      isFrench ? 'Aucune conversation trouvée' : 'No conversations found';

  String get replyToClient =>
      isFrench ? 'Répondre au client...' : 'Reply to client...';

  String get generalInquiry =>
      isFrench ? 'Demande générale' : 'General Inquiry';

  String get senderInformation =>
      isFrench ? 'Informations de l’expéditeur' : 'Sender Information';

  String get transportInformation =>
      isFrench ? 'Informations de transport' : 'Transport Information';

  String get trackingProgress =>
      isFrench ? 'Progression du suivi' : 'Tracking Progress';

  String get nextValidStatus =>
      isFrench ? 'Prochain statut valide' : 'Next Valid Status';

  String get updateStatus =>
      isFrench ? 'Mettre à jour le statut' : 'Update Status';

  String get manageStatus => isFrench ? 'Gérer le statut' : 'Manage Status';

  // ==================================================
  // AGENCY DASHBOARD & OPERATIONS
  // ==================================================

  String get quickActions => isFrench ? 'Actions rapides' : 'Quick Actions';
  String get upcomingTrips => isFrench ? 'Voyages à venir' : 'Upcoming Trips';
  String get recentActivity =>
      isFrench ? 'Activité récente' : 'Recent Activity';

  String get addInterurbanTripSchedule => isFrench
      ? 'Ajoutez un nouvel horaire de voyage interurbain.'
      : 'Add a new interurban trip schedule.';

  String get reviewAgencyBookings => isFrench
      ? 'Consultez les réservations effectuées auprès de votre agence.'
      : 'Review bookings made with your agency.';

  String get updateTravelerLuggageStatus => isFrench
      ? 'Consultez et mettez à jour le statut des bagages des voyageurs.'
      : 'View and update traveler luggage status.';

  String get openClientConversations => isFrench
      ? 'Ouvrez les conversations avec vos clients.'
      : 'Open conversations with your clients.';

  String get newBookingReceived =>
      isFrench ? 'Nouvelle réservation reçue' : 'New booking received';

  String get parcelStatusUpdated =>
      isFrench ? 'Statut du colis mis à jour' : 'Parcel status updated';

  String get newClientMessage =>
      isFrench ? 'Nouveau message client' : 'New client message';

  String get clientSentNewMessage => isFrench
      ? 'Un client a envoyé un nouveau message.'
      : 'A client sent a new message.';

  String minutesAgo(int minutes) =>
      isFrench ? 'Il y a $minutes min' : '$minutes min ago';

  String seatsBooked(int bookedSeats, int totalSeats) => isFrench
      ? '$bookedSeats / $totalSeats places'
      : '$bookedSeats / $totalSeats seats';

  String get agencyNotificationsPending => isFrench
      ? 'Les notifications de l’agence seront connectées ultérieurement.'
      : 'Agency notifications will be connected later.';

  String get agencyOperationsAuthorizationNotice => isFrench
      ? 'Les opérations de l’agence doivent être limitées aux données appartenant à l’agence authentifiée. Le backend appliquera cette autorisation à partir de l’identité de l’agence authentifiée.'
      : 'Agency operations must be restricted to records belonging to the authenticated agency. The backend will enforce this authorization using the authenticated agency identity.';

  // ==================================================
  // ADMIN PORTAL
  // ==================================================

  String get adminDashboard =>
      isFrench ? 'Tableau de bord administrateur' : 'Admin Dashboard';
  String get platformOverview =>
      isFrench ? 'Vue d’ensemble de la plateforme' : 'Platform Overview';
  String get currentEasyGoActivity =>
      isFrench ? 'Activité actuelle de easyGO' : 'Current easyGO activity';
  String get users => isFrench ? 'Utilisateurs' : 'Users';
  String get agencies => isFrench ? 'Agences' : 'Agencies';
  String get activeTrips => isFrench ? 'Voyages actifs' : 'Active Trips';
  String get manageAgencies =>
      isFrench ? 'Gérer les agences' : 'Manage Agencies';
  String get manageAgenciesDescription => isFrench
      ? 'Consultez, vérifiez et supervisez les agences de transport enregistrées.'
      : 'Review, verify and monitor registered transport agencies.';
  String get manageUsers =>
      isFrench ? 'Gérer les utilisateurs' : 'Manage Users';
  String get manageUsersDescription => isFrench
      ? 'Consultez et gérez les comptes utilisateurs de la plateforme.'
      : 'Review and manage platform user accounts.';
  String get monitorOperations =>
      isFrench ? 'Superviser les opérations' : 'Monitor Operations';
  String get monitorOperationsDescription => isFrench
      ? 'Supervisez les voyages, réservations, bagages et colis sur la plateforme.'
      : 'Monitor trips, bookings, luggage and parcel operations across the platform.';
  String get agencyVerification =>
      isFrench ? 'Vérification des agences' : 'Agency Verification';
  String get verified => isFrench ? 'Vérifiée' : 'Verified';
  String get pending => isFrench ? 'En attente' : 'Pending';
  String get suspended => isFrench ? 'Suspendue' : 'Suspended';
  String get welcomeAdministrator =>
      isFrench ? 'Bienvenue, Administrateur' : 'Welcome, Administrator';
  String get adminWelcomeDescription => isFrench
      ? 'Supervisez et gérez la plateforme easyGO.'
      : 'Monitor and manage the easyGO platform.';
  String get latestPlatformEvents => isFrench
      ? 'Derniers événements de la plateforme'
      : 'Latest platform events';
  String get newAgencyRegistered =>
      isFrench ? 'Nouvelle agence enregistrée' : 'New agency registered';
  String get agencyVerificationCompleted => isFrench
      ? 'Vérification d’agence terminée'
      : 'Agency verification completed';
  String get newUserRegistered =>
      isFrench ? 'Nouvel utilisateur enregistré' : 'New user registered';
  String get parcelDelivered => isFrench ? 'Colis livré' : 'Parcel delivered';
  String get adminAuthorizationNotice => isFrench
      ? 'Les actions administratives doivent être autorisées par le backend. L’interface ne doit jamais accorder des privilèges administrateur uniquement à partir de son état local.'
      : 'Administrative actions must be authorized by the backend. The frontend must never grant administrator privileges based only on local interface state.';
  String get agencyManagement =>
      isFrench ? 'Gestion des agences' : 'Agency Management';
  String get searchAgencies =>
      isFrench ? 'Rechercher une agence' : 'Search agencies';
  String get allAdmin => isFrench ? 'Toutes' : 'All';
  String get verifyAgency => isFrench ? 'Vérifier l’agence' : 'Verify Agency';
  String get suspendAgency =>
      isFrench ? 'Suspendre l’agence' : 'Suspend Agency';
  String get reactivateAgency =>
      isFrench ? 'Réactiver l’agence' : 'Reactivate Agency';
  String get verificationStatus =>
      isFrench ? 'Statut de vérification' : 'Verification Status';
  String get registeredOn => isFrench ? 'Enregistrée le' : 'Registered On';
  String get totalTrips => isFrench ? 'Total des voyages' : 'Total Trips';
  String get totalBookings =>
      isFrench ? 'Total des réservations' : 'Total Bookings';
  String get userManagement =>
      isFrench ? 'Gestion des utilisateurs' : 'User Management';
  String get searchUsers =>
      isFrench ? 'Rechercher un utilisateur' : 'Search users';
  String get userDetails =>
      isFrench ? 'Détails de l’utilisateur' : 'User Details';
  String get accountStatus => isFrench ? 'Statut du compte' : 'Account Status';
  String get registeredDate =>
      isFrench ? 'Date d’inscription' : 'Registration Date';
  String get completedTrips =>
      isFrench ? 'Voyages terminés' : 'Completed Trips';
  String get suspendUser =>
      isFrench ? 'Suspendre l’utilisateur' : 'Suspend User';
  String get activateUser =>
      isFrench ? 'Activer l’utilisateur' : 'Activate User';
  String get operationsMonitoring =>
      isFrench ? 'Supervision des opérations' : 'Operations Monitoring';
  String get operationsMonitoringDescription => isFrench
      ? 'Consultez les opérations easyGO à l’échelle de la plateforme.'
      : 'Review easyGO operations across the platform.';
  String get monitorTrips =>
      isFrench ? 'Superviser les voyages' : 'Monitor Trips';
  String get monitorBookings =>
      isFrench ? 'Superviser les réservations' : 'Monitor Bookings';
  String get monitorLuggage =>
      isFrench ? 'Superviser les bagages' : 'Monitor Luggage';
  String get monitorParcels =>
      isFrench ? 'Superviser les colis' : 'Monitor Parcels';
  String get platformTrips =>
      isFrench ? 'Voyages de la plateforme' : 'Platform Trips';
  String get platformBookings =>
      isFrench ? 'Réservations de la plateforme' : 'Platform Bookings';
  String get platformLuggage =>
      isFrench ? 'Bagages de la plateforme' : 'Platform Luggage';
  String get platformParcels =>
      isFrench ? 'Colis de la plateforme' : 'Platform Parcels';
  String get adminOperationsReadOnlyNotice => isFrench
      ? 'L’administrateur supervise ces opérations. La gestion opérationnelle normale reste sous la responsabilité de l’agence concernée.'
      : 'The administrator monitors these operations. Normal operational management remains the responsibility of the relevant agency.';
  String get markAllAsRead =>
      isFrench ? 'Tout marquer comme lu' : 'Mark All as Read';
  String get adminProfile =>
      isFrench ? 'Profil administrateur' : 'Admin Profile';
  String get administrator => isFrench ? 'Administrateur' : 'Administrator';
  String get platformAdministration =>
      isFrench ? 'Administration de la plateforme' : 'Platform Administration';
  String get adminProfileNotice => isFrench
      ? 'Les privilèges administrateur doivent provenir de l’identité authentifiée et être vérifiés par le backend.'
      : 'Administrator privileges must come from the authenticated identity and be verified by the backend.';
  String get prototypeAdminNotice => isFrench
      ? 'Mode prototype : cette action est simulée localement. Le backend sera l’autorité en production.'
      : 'Prototype mode: this action is simulated locally. The backend will be authoritative in production.';

  String adminAgencyStatusLabel(String status) {
    switch (status) {
      case 'Verified':
        return verified;
      case 'Pending':
        return pending;
      case 'Suspended':
        return suspended;
      default:
        return status;
    }
  }

  String adminUserStatusLabel(String status) {
    switch (status) {
      case 'Active':
        return active;
      case 'Suspended':
        return suspended;
      default:
        return status;
    }
  }

  String agencyBookingStatusLabel(String status) {
    switch (status) {
      case 'Confirmed':
        return isFrench ? 'Confirmée' : 'Confirmed';
      case 'Completed':
        return isFrench ? 'Terminée' : 'Completed';
      case 'Cancelled':
        return isFrench ? 'Annulée' : 'Cancelled';
      default:
        return status;
    }
  }

  String agencyTripStatusLabel(String status) {
    switch (status) {
      case 'Scheduled':
        return isFrench ? 'Programmé' : 'Scheduled';
      case 'Completed':
        return isFrench ? 'Terminé' : 'Completed';
      case 'Cancelled':
        return isFrench ? 'Annulé' : 'Cancelled';
      default:
        return status;
    }
  }

  String agencyContextTypeLabel(String type) {
    switch (type) {
      case 'Booking':
        return isFrench ? 'Réservation' : 'Booking';
      case 'Parcel':
        return isFrench ? 'Colis' : 'Parcel';
      case 'General':
        return isFrench ? 'Général' : 'General';
      default:
        return type;
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) {
    return false;
  }
}
