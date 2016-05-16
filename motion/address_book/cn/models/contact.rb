module AddressBook
  module CN
    class Contact
      # NOTE: These values don't come through via the REPL, you have to open up
      #   an Xcode playground to get them.
      PROPERTY_MAP = {
        # Single-values
        "namePrefix"           => :prefix,                 # CNContactNamePrefixKey
        "givenName"            => :first_name,             # CNContactGivenNameKey
        "middleName"           => :middle_name,            # CNContactMiddleNameKey
        "familyName"           => :last_name,              # CNContactFamilyNameKey
        "previousFamilyName"   => :maiden_name,            # CNContactPreviousFamilyNameKey
        "nameSuffix"           => :suffix,                 # CNContactNameSuffixKey
        "nickname"             => :nickname,               # CNContactNicknameKey
        "phoneticGivenName"    => :first_name_phonetic,    # CNContactPhoneticGivenNameKey
        "phoneticMiddleName"   => :last_name_phonetic,     # CNContactPhoneticMiddleNameKey
        "phoneticFamilyName"   => :middle_name_phonetic,   # CNContactPhoneticFamilyNameKey
        "organizationName"     => :organization,           # CNContactOrganizationNameKey
        "departmentName"       => :department,             # CNContactDepartmentNameKey
        "jobTitle"             => :job_title,              # CNContactJobTitleKey
        "birthday"             => :birthday,               # CNContactBirthdayKey
        "nonGregorianBirthday" => :non_gregorian_birthday, # CNContactNonGregorianBirthdayKey
        "note"                 => :note,                   # CNContactNoteKey
        "imageData"            => :image,                  # CNContactImageDataKey
        "thumbnailImageData"   => :thumbnail_image,        # CNContactThumbnailImageDataKey
        "imageDataAvailable"   => :image_available,        # CNContactImageDataAvailableKey
        "contactType"          => :contact_type,           # CNContactTypeKey
        # Multi-values
        "phoneNumbers"            => :phones,          # CNContactPhoneNumbersKey
        "emailAddresses"          => :emails,          # CNContactEmailAddressesKey
        "postalAddresses"         => :addresses,       # CNContactPostalAddressesKey
        "dates"                   => :dates,           # CNContactDatesKey
        "urlAddresses"            => :urls,            # CNContactUrlAddressesKey
        "contactRelations"        => :relationsh,      # CNContactRelationsKey
        "socialProfiles"          => :social_profiles, # CNContactSocialProfilesKey
        "instantMessageAddresses" => :im_profiles      # CNContactInstantMessageAddressesKey
      }

      attr_accessor(
        # Single-values
        :prefix,
        :first_name,
        :middle_name,
        :last_name,
        :maiden_name,
        :suffix,
        :nickname,
        :first_name_phonetic,
        :last_name_phonetic,
        :middle_name_phonetic,
        :organization,
        :department,
        :job_title,
        :birthday,
        :non_gregorian_birthday,
        :note,
        :image,
        :thumbnail_image,
        :image_available,
        :contact_type,
        # Multi-values
        :phones,
        :emails,
        :addresses,
        :dates,
        :urls,
        :relationsh,
        :social_profiles,
        :im_profiles
      )
    end
  end
end
