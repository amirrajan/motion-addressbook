module AddressBook
  module AB
    class Source
      def initialize(ab_source)
        @ab_source = ab_source
      end

      def type
        Accessors::Source.type(ab_source)
      end

      def local?
        type == KABSourceTypeLocal
      end

      private

      def ab_source
        @ab_source
      end
    end
  end
end
