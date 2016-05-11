module AddressBook
  module AB
    module Utilities
      module_function

      def address_book?(reference)
        pointer_for?("ABCAddressBook", reference)
      end

      def group?(reference)
        ABRecordGetRecordType(reference) == KABGroupType
      end

      def multi_value?(reference)
        pointer_for?("ABMultiValueRef", reference)
      end

      def person?(reference)
        ABRecordGetRecordType(reference) == KABPersonType
      end

      def pointer_for?(class_name, reference)
        reference && reference.description.include?(class_name)
      end
    end
  end
end
