module AddressBook
  module CN
    class LabeledValue
      KNOWN_VALUE_TYPES = [
        :address,
        :im_address,
        :phone,
        :relation,
        :simple,
        :social_profile
      ]
      INITIALIZATION_ERROR =
        "LabeledValue must be initialized with an CNLabeledValue or Hash"

      def self.LABEL_MAP
        {
          # Generic Labels
          :work  => CNLabelWork,
          :home  => CNLabelHome,
          :other => CNLabelOther,
          # Email Labels
          :icloud => CNLabelEmailiCloud,
          # URL Labels
          :home_page => CNLabelURLAddressHomePage,
          # Date Labels
          :anniversary => CNLabelDateAnniversary,
          # Phone Number Labels
          :mobile    => CNLabelPhoneNumberMobile,
          :iphone    => CNLabelPhoneNumberiPhone,
          :main      => CNLabelPhoneNumberMain,
          :home_fax  => CNLabelPhoneNumberHomeFax,
          :work_fax  => CNLabelPhoneNumberWorkFax,
          :other_fax => CNLabelPhoneNumberOtherFax,
          :pager     => CNLabelPhoneNumberPager,
          # Relation Labels
          :father    => CNLabelContactRelationFather,
          :mother    => CNLabelContactRelationMother,
          :parent    => CNLabelContactRelationParent,
          :brother   => CNLabelContactRelationBrother,
          :sister    => CNLabelContactRelationSister,
          :child     => CNLabelContactRelationChild,
          :friend    => CNLabelContactRelationFriend,
          :spouse    => CNLabelContactRelationSpouse,
          :partner   => CNLabelContactRelationPartner,
          :assistant => CNLabelContactRelationAssistant,
          :manager   => CNLabelContactRelationManager
        }
      end

      attr_reader(
        :label,
        :value
      )

      def initialize(hash_or_record)
        # Assign the local variables as appropriate
        if hash_or_record.is_a?(CNLabeledValue)
          parse_record!(hash_or_record)
        elsif hash_or_record.is_a?(Hash)
          parse_hash!(hash_or_record)
        else
          raise(ArugmentError, INITIALIZATION_ERROR)
        end

        self
      end

      def label=(new_value)
        @label = new_value
        @native_ref.label = self.class.LABEL_MAP[new_value]
      end

      def value=(new_value)
        @value = new_value
        @native_ref.value = new_value
      end

      def values
        { label: @label }.merge(@value)
      end
      alias :as_hash :values
      alias :to_ary :values
      alias :to_h :values

      private

      def ruby_hash_to_cn_keys(hash_value)
        case @value_type
        when :phone
          { number: hash_value[:number] }
        when :address
          {
            street: hash_value[:street],
            city: hash_value[:city],
            state: hash_value[:state],
            postalCode: hash_value[:postal_code],
            country: hash_value[:country],
            ISOCountryCode: hash_value[:iso_country_code],
          }
        when :relation
          { name: hash_value[:name] }
        when :im_address
          {
            service: hash_value[:service],
            username: hash_value[:username]
          }
        when :social_profile
          {
            service: hash_value[:service],
            urlString: hash_value[:url_string],
            userIdentifier: hash_value[:user_identifier],
            username: hash_value[:username]
          }
        when :simple
          { value: hash_value[:value] }
        end
      end

      def localized_label(str)
        self.class.LABEL_MAP[str] || str
      end

      def parse_record!(cn_record)
        @native_ref = cn_record
        @label = self.class.LABEL_MAP.invert[cn_record.label]
        parse_record_value!(cn_record.value)
      end

      def parse_record_value!(cn_value)
        case cn_value
        when CNPhoneNumber
          @value_type = :phone
          @value = { number: cn_value.stringValue }
        when CNPostalAddress
          @value_type = :address
          @value = {
            street: cn_value.street,
            city: cn_value.city,
            state: cn_value.state,
            postal_code: cn_value.postalCode,
            country: cn_value.country,
            iso_country_code: cn_value.ISOCountryCode,
          }
        when CNContactRelation
          @value_type = :relation
          @value = { name: cn_value.name }
        when CNInstantMessageAddress
          @value_type = :im_address
          @value = { service: cn_value.service, username: cn_value.username }
        when CNSocialProfile
          @value_type = :social_profile
          @value = {
            service: cn_value.service,
            url_string: cn_value.urlString,
            user_identifier: cn_value.userIdentifier,
            username: cn_value.username
          }
        else
          @value_type = :simple
          @value = { value: cn_value }
        end
      end

      def parse_hash!(hash)
        value_type = hash[:value_type].to_sym
        unless self.class.KNOWN_VALUE_TYPES.include?(value_type)
          raise(ArgumentError, "Invalid value type")
        end
        raise(ArgumentError, "No value given") unless hash[:value]

        @label = hash.delete :label
        @values = hash
        @value_type = value_type

        method =
          case @value_type
          when :phone then :new_phone
          when :address then :new_address
          when :relation then :new_relation
          when :im_address then :new_im_address
          when :social_profile then :new_social_profile
          when :simple then :new_value
          end

        @native_ref = Accessors::LabeledValue.send(method,
          @label, ruby_hash_to_cn_keys(hash[:value])
        )
      end
    end
  end
end
