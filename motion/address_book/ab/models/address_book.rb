module AddressBook
  module AB
    class AddressBook
      # @param autoconnect [Boolean] Whether or not we should automatically
      #   request access on creation
      def initialize(auto_connect = true)
        connect if auto_connect
        self
      end

      def connect(&after_connect)
        if connected?
          return (after_connect.nil? ? @native_ref : after_connect.call)
        end

        if Authorization.granted?
          Accessors::AddressBook.new_connection(@native_ref)
          return after_connect.call
        end

        request_authorization { |success, error| after_connect.call if success }
      end

      # If set, @native_ref will be a __NSCFType, which, unfortunately, is not
      # something you can easily query for, so we check the pointer description
      def connected?
        Utilities.address_book?(@native_ref)
      end

      # @param block [Proc] will receive one boolean argument indicating whether
      #   or not access to the address book was granted. If no block is given,
      #   this request will be blocking
      def request_authorization(&block)
        synchronous = !block

        Authorization.request(@native_ref) do |granted, error|
          NSLog "%@", granted
          NSLog "%@", error
          # not sure what to do with error ... so we're ignoring it
          @access_granted = granted
          block.call(@access_granted) unless block.nil?
        end

        # Wait on the asynchronous callback before returning.
        while(synchronous && @access_granted.nil?) do sleep 0.1 end

        @access_granted
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
        ensure_connection! { register_callback(notifier) }
      end

      def register_callback(callback)
        Accessors::AddressBook.register_callback(@native_ref, callback)
      end

      # @param callback [Proc] will receive 3 arguments on changes to the
      #   address book, the @native_ref that was changed, a nil value, and the
      #   context
      def track_changes(&callback)
        ensure_connection! { register_callback(callback) }
      end

      ###############
      ## Accessors ##
      ###############

      # Groups

      def groups
        ensure_connection! do
          Accessors::Groups.index(@native_ref).map { |group| group_new(group) }
        end
      end

      def groups_count
        ensure_connection! { Accessors::Groups.count(@native_ref) }
      end

      def group_new(attributes)
        ensure_connection! { Group.new(attributes, @native_ref) }
      end

      def group_create(attributes)
        ensure_connection! { group_new(attributes).save }
      end

      def group_find(id)
        ensure_connection! do
          ab_group = Accessors::Groups.find(@native_ref, id)
          ab_group && group_new(ab_group)
        end
      end

      # People

      def people(options = {})
        ensure_connection! do
          Accessors::People.index(@native_ref, options)
            .map { |ab_person| person_new(ab_person) }
        end
      end
      alias :contacts :people

      def people_changed_since(timestamp)
        ensure_connection! do
          Accessors::People.changed_since(@native_ref, timestamp)
        end
      end
      alias :contacts_changed_since :people_changed_since

      def people_count
        ensure_connection! { Accessors::People.count(@native_ref) }
      end
      alias :contacts_count :people_count

      def people_where(conditions)
        ensure_connection! do
          people.select { |person| person.matches? conditions }
        end
      end
      alias :contacts_where :people_where

      def person_new(attributes)
        ensure_connection! { Person.new(attributes, @native_ref) }
      end
      alias :contact_new :person_new

      def person_create(attributes)
        ensure_connection! { person_new(attributes).save }
      end
      alias :contact_create :person_create

      def person_find(id)
        ensure_connection! do
          ab_person = Accessors::People.find(@native_ref, id)
          ab_person && person_new(ab_person)
        end
      end
      alias :contact_find :person_find

      # Sources

      def sources
        ensure_connection! do
          Accessors::Sources.index(@native_ref).map { |s| Source.new(s) }
        end
      end

      private

      def ensure_connection!(&after_connect)
        connected? ? after_connect.call : connect(&after_connect)
      end

      def notifier
        @notifier ||= Proc.new do |_ab_instance, _always_nil, _context|
          NSNotificationCenter.defaultCenter.postNotificationName(
            :addressbook_updated,
            object: self,
            userInfo: nil
          )
        end
      end
    end
  end
end
