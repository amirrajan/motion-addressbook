module AddressBook
  module CN
    class Contact
      include AddressBook::Shared::Hashable

      INITIALIZATION_ERROR =
        "Contact must be initialized with an CNContact or Hash"
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
        "contactRelations"        => :relations,       # CNContactRelationsKey
        "socialProfiles"          => :social_profiles, # CNContactSocialProfilesKey
        "instantMessageAddresses" => :im_profiles      # CNContactInstantMessageAddressesKey
      }
      TYPE_MAP = {
        0 => :person,      # CNContactTypePerson
        1 => :organization # CNContactTypeOrganization
      }

      attr_accessor(*PROPERTY_MAP.values)

      def initialize(hash_or_record)
        if hash_or_record.is_a?(CNContact) then parse_record!(hash_or_record)
        elsif hash_or_record.is_a?(Hash) then parse_hash!(hash_or_record)
        else raise(ArugmentError, INITIALIZATION_ERROR)
        end

        self
      end

      def to_s
        "#<#{self.class}:#{uid}: #{attributes}>"
      end
      alias :inspect :to_s

      def uid
        return unless @record_ref
        @record_ref.identifier
      end

      private

      def parse_record!(cn_contact)
        @record_reference = cn_contact

        @type = TYPE_MAP[@record_reference.contactType]

        PROPERTY_MAP.each do |cn_field, attribute|
          record_property = cn_contact.send(cn_field.to_sym)
          next unless record_property
          instance_variable_set("@#{attribute}".to_sym, record_property)
        end

        self
      end

      def parse_hash!(hash)
        record_reference # Initializes a new record

        @type = TYPE_MAP.invert[hash[:type]]

        PROPERTY_MAP.each do |_cn_field, attribute|
          instance_variable_set("@#{attribute}".to_sym, hash[attribute])
        end

        self
      end
    end
  end
end
