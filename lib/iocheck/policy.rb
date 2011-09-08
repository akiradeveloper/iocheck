module IOCheck

  class Policy
    def initialize
      @result = nil
    end
    attr_reader :result

    # Expected -> Actual -> Success or Failure
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

    class Block < Policy
      def initialize(&blk)
        super
        @blk = blk
      end
  
      def evaluate( test )
        @blk.call( test )
      end
    end

    def self.succeed_if( pred, log )
      if pred
        return Success.new
      else
        return Failure.new(log)
      end
    end

    def self.by_bytes
      Block.new do |test|
        # TODO: Better to show the diff to the user.
	succeed_if(
	  test.actual.bytes == test.expected.bytes,
          by_bytes_log( test ))
      end
    end

    def self.by_bytes_log( test )
      "Bytes not exactly matched.\n" +
      "--------------------------\n" +
      "expected :\n#{test.expected.bytes}\n" +
      "--------------------------\n" +
      "actual   :\n#{test.actual.bytes}" 
    end
  end # end of class Policy
end # end of module IOCheck 
