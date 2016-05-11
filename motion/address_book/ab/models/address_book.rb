module AddressBook
  module AB
    class AddressBook
      # @param autoconnect [Boolean] Whether or not we should automatically
      #   request access on creation
      def initialize(autoconnect = true)
        connect if autoconnect
      end

      def authorized?
        authorization_status == :authorized
      end

      # Will return one of the following:
      # :not_determined
      # :restricted
      # :denied
      # :authorized
      def authorization_status
        Authorization.status
      end

      def connect
        return @connection if connected?

        if authorized?
          options, error = [nil, nil]
          @connection = ABAddressBookCreateWithOptions(options, error)
        else
          Authorization.request(@connection) do |success, error|
            NSLog("AddressBook: access was #{success ? 'approved' : 'denied'}")
          end
        end
      end

      # If set, @connection will be a __NSCFType, which, unfortunately, is not
      # something you can easily query for, so we check the pointer description
      def connected?
        Utilities.address_book?(@connection)
      end

      # @param block [Proc] will receive one boolean argument indicating whether
      #   or not access to the address book was granted. If no block is given,
      #   this request will be blocking
      def request_authorization(&block)
        synchronous = !block

        Authorization.request(@connection) do |granted, error|
          NSLog "%@", granted
          NSLog "%@", error
          # not sure what to do with error ... so we're ignoring it
          @address_book_access_granted = granted
          block.call(@address_book_access_granted) unless block.nil?
        end

        # Wait on the asynchronous callback before returning.
        while(synchronous && @address_book_access_granted.nil?) do sleep 0.1 end

        @address_book_access_granted
      end

      # Will ensure that changes to the address book are emitted via the
      # standard notification center for observation, e.g.
      #
      # notify_on_changes!
      #
      # my_callback = Proc.new do |notification|
      #   NSLog "Address Book was changed!"
      # end
      #
      # NSNotificationCenter.defaultCenter.addObserverForName(
      #   :addressbook_updated,
      #   object: nil,
      #   queue: NSOperationQueue.mainQueue,
      #   usingBlock: my_callback
      # )
      #
      # Or if you're using BubbleWrap:
      #
      # App.notification_center.observe(:addressbook_updated, &my_callback)
      def notify_on_changes!
        ensure_connection!

        @notifier = Proc.new do |_ab_instance, _always_nil, _context|
          NSNotificationCenter.defaultCenter.postNotificationName(
            :addressbook_updated,
            object: self,
            userInfo: nil
          )
        end

        register_callback(@notifier)
      end

      def register_callback(callback)
        ABAddressBookRegisterExternalChangeCallback(@connection, callback, nil)
      end

      # @param callback [Proc] will receive 3 arguments on changes to the
      #   address book, the @connection that was changed, a nil value, and the
      #   context
      def track_changes(&callback)
        ensure_connection!

        register_callback(callback)
      end

      ###############
      ## Accessors ##
      ###############

      # Groups

      def groups
        ensure_connection!

        Accessors::Groups.index(@connection).map { |group| group_new(group) }
      end

      def groups_count
        ensure_connection!

        Accessors::Groups.count(@connection)
      end

      def group_new(attributes)
        ensure_connection!

        Group.new(attributes, @connection)
      end

      def group_create(attributes)
        ensure_connection!

        group_new(attributes).save
      end

      def group_find(id)
        ensure_connection!

        ab_group = Accessors::Groups.find(@connection, id)
        ab_group && group_new(ab_group)
      end

      # People

      def people(options = {})
        ensure_connection!

        Accessors::People.index(@connection, options)
          .map { |ab_person| person_new(ab_person) }
      end
      alias :contacts :people

      def people_changed_since(timestamp)
        ensure_connection!

        Accessors::People.changed_since(@connection, timestamp)
      end
      alias :contacts_changed_since :people_changed_since

      def people_count
        ensure_connection!

        Accessors::People.count(@connection)
      end
      alias :contacts_count :people_count

      def person_new(attributes)
        ensure_connection!

        Person.new(attributes, @connection)
      end
      alias :contact_new :person_new

      def person_create(attributes)
        ensure_connection!

        person_new(attributes).save
      end
      alias :contact_create :person_create

      def person_find(id)
        ensure_connection!

        ab_person = Accessors::People.find(@connection, id)
        ab_person && person_new(ab_person)
      end
      alias :contact_find :person_find

      # Sources

      def sources
        ensure_connection!

        Accessors::Sources.index(@connection).map { |s| Source.new(s) }
      end

      private

      def ensure_connection!
        return if connected? && authorized?
        raise "AddressBook must be created and authorized"
      end
    end
  end
end
