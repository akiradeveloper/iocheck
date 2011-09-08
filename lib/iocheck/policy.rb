module IOCheck

  class Policy
    def initialize
      @result = nil
    end
    attr_reader :result

    # Expected -> Actual -> Either
    def evaluate( test )
      raise NoMethodError, "You must override this method."
    end

    def run!( test )
      @result = evaluate( test )
    end

    class Success
    end

    class Failure
      def initialize(log)
        @log = log
      end
      attr_reader :log 
    end

    class Either
      def initialize(pred, log)
        if pred
	  @stat = ::IOCheck::Policy::Success.new
        else
	  @stat = ::IOCheck::Policy::Failure.new(log)
        end
      end
      def evaluate
        @stat
      end
    end

    class Block < Policy
      def initialize(&blk)
        super
        @blk = blk
      end
  
      def evaluate( test )
        @blk.call( test )
      end
    end

    def self.by_bytes
      Block.new do |test|
        # TODO: Better to show the diff to the user.
        Either.new(
          test.actual.bytes == test.expected.bytes,
  	  "Bytes not exactly matched : #{test}").evaluate
      end
    end
  end # end of class Policy
end # end of module IOCheck 
