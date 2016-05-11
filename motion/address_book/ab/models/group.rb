module AddressBook
  module AB
    class Group
      attr_reader :name

      def initialize(attributes, address_book)
        Utilities.group?(attributes)
      end

      def delete
        raise "#delete has not yet been implemented"
      end

      def persisted?
        raise "#persisted? has not yet been implemented"
      end

      def save
        raise "#save has not yet been implemented"
      end
    end
  end
end
