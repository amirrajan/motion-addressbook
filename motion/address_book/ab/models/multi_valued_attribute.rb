module AddressBook
  module AB
    class MultiValuedAttribute
      INITIALIZATION_ERROR =
        "MultiValuedAttribute must be initialized with an ABMultiValue or Hash"
      LABEL_MAP = {
        :mobile      => "_$!<Mobile>!$_",      # KABPersonPhoneMobileLabel
        :iphone      => "iPhone",              # KABPersonPhoneIPhoneLabel
        :main        => "_$!<Main>!$_",        # KABPersonPhoneMainLabel
        :home_fax    => "_$!<HomeFAX>!$_",     # KABPersonPhoneHomeFAXLabel
        :work_fax    => "_$!<WorkFAX>!$_",     # KABPersonPhoneWorkFAXLabel
        :pager       => "_$!<Pager>!$_",       # KABPersonPhonePagerLabel
        :work        => "_$!<Work>!$_",        # KABWorkLabel
        :home        => "_$!<Home>!$_",        # KABHomeLabel
        :other       => "_$!<Other>!$_",       # KABOtherLabel
        :home_page   => "_$!<HomePage>!$_",    # KABPersonHomePageLabel
        :anniversary => "_$!<Anniversary>!$_", # KABPersonAnniversaryLabel
      }
      PROPERTY_MAP = {
        "Street"      => :street,       # KABPersonAddressStreetKey
        "City"        => :city,         # KABPersonAddressCityKey
        "State"       => :state,        # KABPersonAddressStateKey
        "ZIP"         => :postalcode,   # KABPersonAddressZIPKey
        "Country"     => :country,      # KABPersonAddressCountryKey
        "CountryCode" => :country_code, # KABPersonAddressCountryCodeKey

        "service"    => :service,  # KABPersonSocialProfileServiceKey
        "url"        => :url,      # KABPersonSocialProfileURLKey
        "username"   => :username, # KABPersonSocialProfileUsernameKey
        "identifier" => :userid,   # KABPersonSocialProfileUserIdentifierKey

        # these keys are identical to the SocialProfile keys above
        "service"  => :service, # KABPersonInstantMessageServiceKey
        "username" => :username # KABPersonInstantMessageUsernameKey
      }

      def initialize(value_array_or_record)
        @values = []

        # Assign the local variables as appropriate
        if Utilities.multi_value?(value_array_or_record)
          parse_record!(value_array_or_record)
        elsif value_array_or_record.is_a?(Array)
          parse_value_array!(value_array_or_record)
        else
          raise(ArugmentError, INITIALIZATION_ERROR)
        end

        self
      end

      def [](index)
        values[index]
      end

      # @param value_hash [Hash] Should include something like this:
      #   { value: "My String", label: :main }
      #   { date: NSDate, label: :anniversary }
      def add_value_hash(value_hash)
        add_value_with_label(
          value_from_hash(value_hash),
          localized_label(value_hash[:label])
        )
      end
      alias :<< :add_value_hash

      def ab_multi_value
        attribute_reference
      end

      def property_type
        if attribute_reference then Accessors::MultiValue.property_type(attribute_reference)
        elsif values.find { |rec| rec[:value] } then KABMultiStringPropertyType
        elsif values.find { |rec| rec[:date] } then KABMultiDateTimePropertyType
        else KABMultiDictionaryPropertyType
        end
      end

      def to_s
        "#<#{self.class}: #{values}>"
      end
      alias :inspect :to_s

      def values
        @values
      end
      alias :as_hash :values
      alias :to_ary :values
      alias :to_h :values

      def with_label(label)
        values.select { |value| value[:label] == label.to_s }
      end

      private

      def ab_dictionary_from_hash(hash)
        ab_record = {}
        PROPERTY_MAP.each do |ab_key, ruby_key|
          ab_record[ab_key] = hash[ruby_key] if hash[ruby_key]
        end
        ab_record.empty? ? nil : ab_record
      end

      # Assumes that the label has already been localized
      def add_value_with_label(value, label)
        Accessors::MultiValue.append(attribute_reference, value, label)
      end

      def attribute_reference
        @attribute_reference
      end

      def hash_from_ab_index(index)
        case property_type
        when KABStringPropertyType # 1
          { value: value_at_index(index) }
        when KABDateTimePropertyType # 4
          { date: value_at_index(index) }
        when KABDictionaryPropertyType # 5
          hash_from_ab_dictionary(value_at_index(index))
        else
          raise(TypeError, "Unknown MultiValue property type")
        end
      end

      def hash_from_ab_dictionary(dictionary)
        hash = {}
        PROPERTY_MAP.each do |ab_key, attr_key|
          hash[attr_key] = dictionary[ab_key] if dictionary[ab_key]
        end
        hash.empty? ? nil : hash
      end

      def label_at_index(index)
        Accessors::MultiValue.get_label_at_index(attribute_reference, index)
      end

      def labeled_hash_at_index(index)
        label = LABEL_MAP.invert[label_at_index(index)]
        hash = hash_from_ab_index(index)
        hash.merge(label: label)
      end

      def localized_label(symbol)
        LABEL_MAP[symbol] || symbol.to_s
      end

      def parse_value_array!(value_array)
        if value_array.empty?
          raise ArgumentError, "Empty multi-value objects are not allowed"
        end

        @values = value_array
        attribute_reference # Initializes a new one
        values.each { |value| add_value_hash(value) }
      end

      def parse_record!(record)
        @attribute_reference = Accessors::MultiValue.find(record)
        @values = value_count.times.map { |index| labeled_hash_at_index(index) }
      end

      def value_at_index(index)
        Accessors::MultiValue.get_value_at_index(attribute_reference, index)
      end

      def value_count
        Accessors::MultiValue.count(attribute_reference)
      end

      def value_from_hash(hash)
        case property_type
        when KABMultiStringPropertyType then value_hash[:value]
        when KABMultiDateTimePropertyType then value_hash[:date]
        when KABMultiDictionaryPropertyType then ab_dictionary_from_hash(value_hash)
        else raise(TypeError, "Unknown MultiValue property type")
        end
      end

      def attribute_reference
        @attribute_reference ||= Accessors::MultiValue.new_record(property_type)
      end
    end
  end
end
