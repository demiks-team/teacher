import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'i18n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @students.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get students;

  /// No description provided for @classes.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get classes;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @noClass.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any classes today'**
  String get noClass;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No Data Available'**
  String get noData;

  /// No description provided for @signUpWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signUpWithGoogle;

  /// No description provided for @signUpWithSocialNetworks.
  ///
  /// In en, this message translates to:
  /// **'Sign up with social networks'**
  String get signUpWithSocialNetworks;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create A New Account'**
  String get createAnAccount;

  /// No description provided for @generalError.
  ///
  /// In en, this message translates to:
  /// **'There was a problem. We logged the technical details for further investigation.'**
  String get generalError;

  /// No description provided for @passwordComplexity.
  ///
  /// In en, this message translates to:
  /// **'Passwords must be at least 8 characters and contain at 3 of the following: upper case (A-Z), lower case (a-z), number (0-9) and special character (e.g. !@#\$%^&*)'**
  String get passwordComplexity;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Wrong username or password.'**
  String get authFailed;

  /// No description provided for @notificationDismiss.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get notificationDismiss;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get loginWithGoogle;

  /// No description provided for @loginWithSocialNetworks.
  ///
  /// In en, this message translates to:
  /// **'Login with social networks'**
  String get loginWithSocialNetworks;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot my password'**
  String get forgotPassword;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @studentNote.
  ///
  /// In en, this message translates to:
  /// **'Notes for students'**
  String get studentNote;

  /// No description provided for @recordOfWork.
  ///
  /// In en, this message translates to:
  /// **'Notes, record of work, ...'**
  String get recordOfWork;

  /// No description provided for @internalNote.
  ///
  /// In en, this message translates to:
  /// **'Internal notes'**
  String get internalNote;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @addOtherStudentsToAttendanceList.
  ///
  /// In en, this message translates to:
  /// **'Do you want to add other students to the attendance list?'**
  String get addOtherStudentsToAttendanceList;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @requested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get requested;

  /// No description provided for @missedAttendances.
  ///
  /// In en, this message translates to:
  /// **'Missed Attendances'**
  String get missedAttendances;

  /// No description provided for @missedAttendancesEmptyList.
  ///
  /// In en, this message translates to:
  /// **'Good job! You\'ve all done with the class attendance.'**
  String get missedAttendancesEmptyList;

  /// No description provided for @listOfTodaysClasses.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Classes'**
  String get listOfTodaysClasses;

  /// No description provided for @tempRegistrationPath.
  ///
  /// In en, this message translates to:
  /// **'Please consider creating an account on Demiks Admin first.'**
  String get tempRegistrationPath;

  /// No description provided for @duplicateEmail.
  ///
  /// In en, this message translates to:
  /// **'Another item with the same email already exists.'**
  String get duplicateEmail;

  /// No description provided for @breakTimeMinutesBreak.
  ///
  /// In en, this message translates to:
  /// **'value minutes break'**
  String get breakTimeMinutesBreak;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @verificationCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Please check your email and enter the code here'**
  String get verificationCodeDescription;

  /// No description provided for @verificationDoesNotMatch.
  ///
  /// In en, this message translates to:
  /// **'This code does not match. Please try again.'**
  String get verificationDoesNotMatch;

  /// No description provided for @continueCapital.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueCapital;

  /// No description provided for @beforeEmailValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email to create an account.'**
  String get beforeEmailValidation;

  /// No description provided for @verificationCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'Your verification code has expired. Please start the process again.'**
  String get verificationCodeExpired;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'The data provided for this operation is not valid or it is incomplete.'**
  String get validationError;

  /// No description provided for @chapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get chapters;

  /// No description provided for @bookNameAttendanceHint.
  ///
  /// In en, this message translates to:
  /// **'Which chapter of bookName did you work on today?'**
  String get bookNameAttendanceHint;

  /// No description provided for @noUserFound.
  ///
  /// In en, this message translates to:
  /// **'No user found with this email. Please sign up first.'**
  String get noUserFound;

  /// No description provided for @absenceInMinutes.
  ///
  /// In en, this message translates to:
  /// **'Absence in Minutes'**
  String get absenceInMinutes;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get invalid;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
