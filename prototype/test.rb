require_relative "policy"
require_relative "tester"

module IOCheck

  def self.name(cmdname)
    cn = cmdname.clone
    if cn.start_with?( "./" )
      cn[0..1] = "dotslash"
    end
    cn.split(" ").join("_")
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
      raise ArgumentError, "readfile not found."
    end
    x
  end

  def self.writefile(name)
    dir = ::IOCheck::Env["dir"]
    "#{dir}/unlock/#{name}"
  end

  def self.include?(name, dir)
    Dir.open(dir).each do |f|
      return true if f == name
    end   
    return false
  end

  class Test

    def initialize(cmdname)
      @command = Command.new(cmdname)
      @policies = [Policy.by_bytes]
      @repeat = 1
      @desc = ""
    end
    attr_reader :com

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
      do_run!
      filename = ::IOCheck.writefile(name)
      f = File.open(filename, "w")
      f.write( @command.actual.bytes )
      f.close
    end

    def with_name(s)
      @name = s
      self
    end
  
    def name
      # puts "Test#name #{@command.cmdname}"
      ::IOCheck.name( @command.cmdname )
    end

    def do_run!
      @command.run!(@repeat)
    end

    def run!
      do_run!
      @policies.each do |p|
        p.run!( @command.actual, expected )
      end
    end

    def ready
      RakeTask.new(self).create_tasks
    end
  
    def show
      n_success = 0
      n_failure = 0
      log = []
      @policies.each do |p|
        if p.result.class == ::IOCheck::Policy::Success
	  n_success += 1
	elsif p.result.class == ::IOCheck::Policy::Failure
	  n_failure += 1
	  log << p.result.log
        else
	  raise Error
        end
      end
      puts "Testname : #{name}"
      puts "Minor Success : #{n_success}"
      puts "Minor Failure : #{n_failure}"
      puts "Log ---"
      puts log.join("\n")
    end

  private

    def expected
      Expected.new(self)
    end

    class Command
      def initialize(cmdname)
        @cmdname = cmdname
	# puts "Command init #{@cmdname}"
        @actual = Actual.new
      end
      attr_reader :cmdname, :actual
    
      def run!(repeat)
        # puts "Command run! #{@cmdname}"
        repeat.times do 
          @actual << Actual::Result.new( @cmdname )
        end
        @actual.repeat  = repeat
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
	    # puts "Result init #{cmdname}"
	    @cmdname = cmdname
	    run!
          end
	  attr_reader :bytes
        private  
	  def run!
	    # TODO: more things like measuring the time.
	    x = `#{@cmdname}`
	    @bytes = ::IOCheck.strip( x )
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
  	  namespace "update" do
	    p @test.name
	    p self
  	    task @test.name do
  	      @test.update!
            end
  	  end
	end
      end
      def create_run_task
        namespace "iocheck" do
	  task @test.name do
	    @test.run!
	    @test.show
	  end
	end
      end
    end # end of class RakeTask
  end # end of class Test
end # end of module IOCheck

if __FILE__ == $0
  p ::IOCheck.name("tree")
  p ::IOCheck.writefile("tree")
  p ::IOCheck.readfile("tree")
  p ::IOCheck.strip("\n aa bbb\n  ccff \n ")
end
