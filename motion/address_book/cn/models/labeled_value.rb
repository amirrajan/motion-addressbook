module AddressBook
  module CN
    class LabeledValue
      LABEL_MAP = {
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
      INITIALIZATION_ERROR =
        "LabeledValue must be initialized with an CNLabeledValue or Hash"

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
        @native_ref.label = LABEL_MAP[new_value]
      end

      def value=(new_value)
        @value = new_value
        @native_ref.value = new_value
      end

      private

      def localized_label(str)
        LABEL_MAP[str] || str
      end

      def parse_record!(cn_record)
        @native_ref = cn_record
        @label = LABEL_MAP.invert[cn_record.label]
        @value = cn_record.value
      end

      def parse_hash!(hash)
        @label = hash[:label]
        @value = hash[:value]
        @native_ref = Accessors::LabeledValue.new(@label, @value)
      end
    end
  end
end
