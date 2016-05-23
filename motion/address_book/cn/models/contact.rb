module AddressBook
  module CN
    class Contact
      include Common::PublicInterface::Contact

      INITIALIZATION_ERROR =
        "Contact must be initialized with an CNContact or Hash"
      MULTI_VALUE_PROPERTY_MAP = {
        CNContactPhoneNumbersKey            => :phones,
        CNContactEmailAddressesKey          => :emails,
        CNContactPostalAddressesKey         => :addresses,
        CNContactDatesKey                   => :dates,
        CNContactUrlAddressesKey            => :urls,
        CNContactRelationsKey               => :relations,
        CNContactSocialProfilesKey          => :social_profiles,
        CNContactInstantMessageAddressesKey => :im_profiles
      }
      PROPERTY_MAP = {
        CNContactNamePrefixKey           => :prefix,
        CNContactGivenNameKey            => :first_name,
        CNContactMiddleNameKey           => :middle_name,
        CNContactFamilyNameKey           => :last_name,
        CNContactPreviousFamilyNameKey   => :maiden_name,
        CNContactNameSuffixKey           => :suffix,
        CNContactNicknameKey             => :nickname,
        CNContactPhoneticGivenNameKey    => :first_name_phonetic,
        CNContactPhoneticMiddleNameKey   => :last_name_phonetic,
        CNContactPhoneticFamilyNameKey   => :middle_name_phonetic,
        CNContactOrganizationNameKey     => :organization,
        CNContactDepartmentNameKey       => :department,
        CNContactJobTitleKey             => :job_title,
        CNContactBirthdayKey             => :birthday,
        CNContactNonGregorianBirthdayKey => :non_gregorian_birthday,
        CNContactNoteKey                 => :note,
        CNContactImageDataKey            => :image,
        CNContactThumbnailImageDataKey   => :thumbnail_image,
        CNContactImageDataAvailableKey   => :image_available,
        CNContactTypeKey                 => :contact_type,
      }
      TYPE_MAP = {
        CNContactTypePerson => :person,
        CNContactTypeOrganization => :organization
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
