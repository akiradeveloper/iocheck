require_relative "policy"

module IOCheck

  def self.name(cmdname)
    cmdname.split(" ").join("_")
  end

  def self.strip(bytes)
    bytes.strip
  end

  def self.readfile(name)
    dir = ::IOCheck::Env["dir"]
    if self.include?(name, "#{dir}/lock") 
      x = "#{dir}/lock/#{name}"
    elsif self.include?(name, "#{dir}/unlock")
      x = "#{dir}/unlock/#{name}"
    else
      raise ArgumentError
    end
    x
  end

  def self.writefile(name)
    "#{dir}/unlock/#{name}"
  end

  def self.include?(name, dir)
    Dir.open(dir).each do |f|
      return true if f == name
    end   
      return false
    end
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

    def by(policy)
      @policies << policy
      self
    end

    def update!
      # if the file is in lock dir, do nothing and return.
      return if ::IOCheck.include?(name, "#{::IOCheck::Env["dir"]}/lock")

      # if not, the file for this test should be updated.
      @command.run!
      bytes = @command.actual.bytes
      filename = ::IOCheck.writefile(name)
      f = File.open(filename)
      f.write(bytes)
      f.close
    end
  
    def name
      ::IOCheck.name( @command.cmdname )
    end

    def taskname
      "iocheck:" + name
    end
  
    def run!
      @command.run!
      @policies.each do |p|
        p.run!( @command.actual, expected )
      end
    end

    def ready
      RakeTask.new(self).create_tasks
    end
  
    def show
      puts "test.show"
      n_success = 0
      n_failure = 0
      log = []
      @policies.each do |p|
        if p.result.class == Success
	  n_success += 1
	elsif p.result.class == Failure
	  n_failure += 1
	  log << p.result.log
        else
	  raise Error
        end
      end
      puts "Testname : #{name}"
      puts "Minor Success : #{n_success}"
      puts "Minor Failure : #{n_failure}"
      puts "Log"
      puts log.join("\n")
    end

  private

    def expected
      Expected.new(self)
    end

    class Command
      def initialize(cmdname)
        @cmdname = cmdname
        @actual = Actual.new
      end
      attr_reader :cmdname, :actual
    
      def run!(time)
        time.times do |t|
          @actual << Actual::Result.new(@cmdname)
        end
        @actual.repeat  = time
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
	  ::IOCheck.strip( @results[0].bytes )
        end

        class Result
          def initialize(cmdname)
	    @cmdname = cmdname
          end
	  attr_reader :bytes
          
	  def run!
	    @bytes = ::IOCheck.strip(`#{@cmdname}`)
	  end
        end # end of class Result
      end # end of class Actual
    end # end of class Command

    class Expected

      def initialize(test)
        @test = test
      end

      def repeat
        @test.repeat
      end
      
      def bytes
        content = File.read( ::IOCheck.readfile(@test.name) )
        ::IOCheck.strip( content )
      end
    end # end of class Expected

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
	  test.update!
	end
      end
      def craete_run_task
        namespace "iocheck" do
	  test.run!
	  test.show
	end
      end
    end # end of class RakeTask
  end # end of class Test
end # end of module IOCheck
