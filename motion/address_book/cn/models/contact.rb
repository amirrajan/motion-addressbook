module AddressBook
  module CN
    class Contact
      include Common::PublicInterface::Contact

      INITIALIZATION_ERROR =
        "Contact must be initialized with an CNContact or Hash"
      MULTI_VALUE_PROPERTY_MAP = {
        "phoneNumbers"            => :phones,          # CNContactPhoneNumbersKey
        "emailAddresses"          => :emails,          # CNContactEmailAddressesKey
        "postalAddresses"         => :addresses,       # CNContactPostalAddressesKey
        "dates"                   => :dates,           # CNContactDatesKey
        "urlAddresses"            => :urls,            # CNContactUrlAddressesKey
        "contactRelations"        => :relations,       # CNContactRelationsKey
        "socialProfiles"          => :social_profiles, # CNContactSocialProfilesKey
        "instantMessageAddresses" => :im_profiles      # CNContactInstantMessageAddressesKey
      }
      PROPERTY_MAP = {
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
      }
      TYPE_MAP = {
        0 => :person,      # CNContactTypePerson
        1 => :organization # CNContactTypeOrganization
      }
      ALL_PROPERTIES = PROPERTY_MAP.merge(MULTI_VALUE_PROPERTY_MAP)

      attr_accessor(*CN_ATTRIBUTES)

      def initialize(hash_or_record)
        if hash_or_record.is_a?(CNContact) then parse_record!(hash_or_record)
        elsif hash_or_record.is_a?(Hash) then parse_hash!(hash_or_record)
        else raise(ArugmentError, INITIALIZATION_ERROR)
        end

        self
      end

      def method_missing(method_name, *args, &block)
        return nil if (AB_ATTRIBUTES - CN_ATTRIBUTES).include?(method_name)
        super
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

      def get_field(cn_field)
        value = record_reference.send(cn_field.to_sym)

        return value if single_valued_field?(cn_field)

        if multi_valued_field?(cn_field)
          return value.map { |labeled_value| LabeledValue.new(labeled_value) }
        end

        NSLog "Unknown field: #{cn_field} -- #{value}"
      end

      def multi_valued_field?(cn_field)
        MULTI_VALUE_PROPERTY_MAP.keys.include? cn_field
      end

      def parse_record!(cn_contact)
        @record_reference = cn_contact

        @type = TYPE_MAP[record_reference.contactType]

        ALL_PROPERTIES.each do |cn_field, attribute|
          next if attribute == :contact_type
          record_property = get_field(cn_field)
          next unless record_property
          instance_variable_set("@#{attribute}".to_sym, record_property)
        end

        self
      end

      def parse_hash!(hash)
        record_reference # Initializes a new record

        @type = TYPE_MAP.invert[hash[:type]]

        PROPERTY_MAP.each do |_cn_field, attribute|
          next if attribute == :contact_type
          instance_variable_set("@#{attribute}".to_sym, hash[attribute])
        end

        self
      end

      def record_reference
        @record_reference ||= Accessors::Contacts.new_record
      end

      def single_valued_field?(cn_field)
        PROPERTY_MAP.keys.include? cn_field
      end
    end
  end
end
