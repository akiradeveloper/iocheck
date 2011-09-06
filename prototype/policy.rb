module IOCheck

  class Policy

    def initialize
      @result = nil
    end
    attr_reader :result

    # Expected -> Actual -> Either
    def evaluate(expected, actual)
      raise "You must implement this method."
    end

    def run!(expected, actual)
      @result = evaluate(expected, actual)
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
  
      def evaluate(expected, actual)
        @blk.call(expected, actual)
      end
    end

    Bytes = Block.new do |actual, expected|
      Either.new(
        actual.bytes == expected.bytes,
	"Bytes not exactly matched").evaluate
    end
  end # end of class Policy

end # end of module IOCheck 
