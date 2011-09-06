require_relative "policy"

module IOCheck

  def self.name(cmdname)
    cmdname.split(" ").join
  end

  def self.strip(bytes)
    bytes.strip
  end

  class Test
  
    def initialize(cmdname)
      @command = Command.new(cmdname)
      @policies = [Policy::Bytes]
      @repeat = 1
      @desc = ""
    end

    def repeat(n)
      @repeat = n
      self 
    end

    def describe(desc)
      @desc = desc
      self
    end
      
    def <<(policy)
      @policies << policy
    end
  
    def name
      IOCheck.name( @command.name )
    end
  
    def run!
      @command.run!(@repeat)
      @policies.each do |p|
        p.run!( @command.actual, expected )
      end
    end

    def ready
      RakeTask.new(self).create_tasks
    end
  
  private
    def expected
      Expected.new(self)
    end

    class RakeTask
      def initialize(test)
        @test = test
      end
      def create_tasks
        create_update_task
	create_run_task
      end
      def create_update_task
        namespace "iocheck" do
	  test.update
	end
      end
      def craete_run_task
        namespace "iocheck" do
	  test.run!
	  test.show
	end
      end
    end
  
    class Command
      def initialize(cmdname)
        @cmdname = cmdname
        @actual = Actual.new
      end
    
      def run!(time)
        time.times do |t|
          @actual << Actual::Result.new(@cmdname)
        end
        @actual.times  = time
      end
  
      class Actual
  
        def initialize
          @results = []
        end
        attr_accessor :repeat
  
        def <<(result)
	  @results << result
        end
  
        def bytes
	  IOCheck.strip( @results[0].bytes )
        end

        class Result
          def initialize(cmdname)
	    @cmdname = cmdname
          end
	  attr_reader :bytes
          
	  def run!
	    @bytes = `#{@cmdname}`
	  end
        end
      end
    end # end of class Command

    class Expected

      def initialize(test)
        @test = test
        if include?(name, "#{test.dir}/lock") 
	  @fname = "#{test.dir}/lock/#{name}"
        elsif include?(name, "#{test.dir}/unlock")
	  @fname = "#{test.dir}/unlock/#{name}"
	else
	  raise
        end
      end

      def repeat
        @test.repeat
      end
      
      def bytes
        IOCheck.strip( `cat #{@fname}` )
      end

    private
      def include?(name, dir)
        Dir.open(dir).each do |f|
	  return true if f == name
	end   
	return false
      end
    end
  end # end of class Test
end # end of module IOCheck
