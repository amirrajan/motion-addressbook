module AddressBook
  module AB
    class Person
      include AddressBook::Shared::Hashable

      def self.MULTI_VALUE_PROPERTY_MAP
        {
          KABPersonPhoneProperty => :phones,
          KABPersonEmailProperty => :emails,
          KABPersonAddressProperty => :addresses,
          KABPersonDateProperty => :dates,
          KABPersonInstantMessageProperty => :im_profiles,
          KABPersonURLProperty => :urls,
          KABPersonRelatedNamesProperty => :related_names,
          KABPersonSocialProfileProperty => :social_profiles
        }
      end

      def self.PROPERTY_MAP
        {
          KABPersonFirstNameProperty => :first_name,
          KABPersonLastNameProperty => :last_name,
          KABPersonMiddleNameProperty => :middle_name,
          # KABPersonFirstNamePhoneticProperty => :first_name_phonetic,
          # KABPersonLastNamePhoneticProperty => :last_name_phonetic,
          # KABPersonMiddleNamePhoneticProperty => :middle_name_phonetic,
          KABPersonOrganizationProperty => :organization,
          KABPersonDepartmentProperty => :department,
          KABPersonNoteProperty => :note,
          KABPersonBirthdayProperty => :birthday,
          KABPersonJobTitleProperty => :job_title,
          KABPersonNicknameProperty => :nickname,
          KABPersonPrefixProperty => :prefix,
          KABPersonSuffixProperty => :suffix,
          KABPersonCreationDateProperty => :creation_date,
          KABPersonModificationDateProperty => :modification_date
        }
      end

      def self.TYPE_MAP
        {
          KABPersonKindPerson => :person,
          KABPersonKindOrganization => :organization
        }
      end

      def self.ALL_PROPERTIES
        self.PROPERTY_MAP.merge(self.MULTI_VALUE_PROPERTY_MAP)
      end

      attr_accessor(
        # Single-values
        :first_name,
        :last_name,
        :middle_name,
        :organization,
        :department,
        :note,
        :birthday,
        :job_title,
        :nickname,
        :prefix,
        :suffix,
        :creation_date,
        :modification_date,
        # Multi-values
        :phones,
        :emails,
        :addresses,
        :dates,
        :im_profiles,
        :urls,
        :related_names,
        :social_profiles,
      )

      attr_reader :type

      def initialize(hash_or_record, address_book = nil)
        @address_book = address_book || AddressBook.instance

        # Assign the local variables as appropriate
        if Utilities.person?(hash_or_record)
          parse_record!(hash_or_record)
        elsif hash_or_record.is_a? Hash
          parse_hash!(hash_or_record)
        else
          raise ArugmentError,
            "Person must be initialized with an ABRecord or Hash"
        end

        self
      end

      def delete!
        raise "Cannot delete non-persisted record" unless persisted?

        Accessors::People.remove_record(address_book, record_reference)
        Accessors::AddressBook.save(address_book)
        @record_reference = nil

        self
      end

      def matches?(conditions)
        conditions.keys.all? do |attribute|
          required_value = conditions[attribute]

          case attribute
          when :email, :phone
            send("#{attribute}s".to_sym).map { |record| record[:value] }
              .any? { |value| value == required_value }
          else
            send(attribute) == required_value
          end
        end
      end

      def organization?
        type == :organization
      end

      def persisted?
        uid != KABRecordInvalidID
      end

      def person?
        type == :person
      end

      def save!
        if persisted?
          instance_variables.each do |variable|
            key = Shared::Utilities.variable_as_sym(var)
            variable_sym = variable_as_sym(variable)
            ab_field = self.class.ALL_PROPERTIES.invert[variable_sym]
            next unless ab_field
            new_value = instance_variable_get(variable_sym)
            new_value ? set_field(ab_field, new_value) : remove_field(ab_field)
          end
        else
          Accessors::People.add_record(address_book, record_reference)
        end

        Accessors::AddressBook.save(address_book)

        self
      end

      def to_s
        "#<#{self.class}:#{uid}: #{attributes}>"
      end
      alias :inspect :to_s

      def uid
        Accessors::People.get_uid(record_reference)
      end

      private

      def address_book
        @address_book
      end

      def get_field(ab_field)
        if multi_valued_field?(ab_field)
          multi_value = Accessors::People.get_field(record_reference, ab_field)
          return [] unless multi_value
          MultiValuedAttribute.new(multi_value)
        elsif single_valued_field?(ab_field)
          Accessors::People.get_field(record_reference, ab_field)
        else
          result = Accessors::People.get_field(record_reference, ab_field)
          NSLog "Unknown field: #{ab_field} -- #{result}"
        end
      end

      def multi_valued_field?(ab_field)
        self.class.MULTI_VALUE_PROPERTY_MAP.keys.include? ab_field
      end

      def parse_record!(ab_record)
        @record_reference = ab_record

        @type = self.class.TYPE_MAP[get_field(KABPersonKindProperty)]

        self.class.ALL_PROPERTIES.each do |ab_field, attribute|
          record_property = get_field(ab_field)
          next unless record_property
          instance_variable_set("@#{attribute}".to_sym, record_property)
        end

        self
      end

      def parse_hash!(hash)
        record_reference # Initializes a new record

        @type = self.class.TYPE_MAP.invert[hash[:type]]

        self.class.ALL_PROPERTIES.each do |_ab_field, attribute|
          instance_variable_set("@#{attribute}".to_sym, hash[attribute])
        end

        self
      end

      def record_reference
        @record_reference ||= Accessors::People.new_record
      end

      def remove_field(ab_field)
        Accessors::People.remove_field(record_reference, ab_field)
      end

      def set_field(ab_field, value)
        if multi_valued_field?(ab_field)
          values = value.map { |val| val.is_a?(String) ? { value: val } : val }

          return unless values && values.any?

          multi_field = MultiValuedAttribute.new(values)

          Accessors::People.set_field(record_reference,
            ab_field, multi_field.ab_multi_value
          )
        elsif single_valued_field?(ab_field)
          Accessors::People.set_field(record_reference, ab_field, value)
        else
          raise TypeError, "Unknown field: #{ab_field}"
        end
      end

      def single_valued_field?(ab_field)
        self.class.PROPERTY_MAP.keys.include? ab_field
      end
    end
  end
end
