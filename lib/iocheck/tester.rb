module IOCheck

  Env = {}
  ::IOCheck::Env["dir"] = "./iocheck"
  
  class Tester
  
    def initialize
      @tests = []
    end
    
    def <<(test)
      @tests << test
    end
  
    def run!
      @tests.each { |t| t.run! }
    end

    def update!
      @tests.each { |t| t.update! }
    end
  
    def ready
      @tests.each do |t|
        t.ready
      end
      namespace "iocheck" do
        desc( "update all the tests except locked ones" )
        task "update" => @tests.map { |t| "iocheck:update:#{t.name}" }
      end
      desc( "run all the tests" )
      task "iocheck" do
        run!
	show
      end
      create_lock_tasks
    end

    def create_lock_tasks
      locked = @tests.select { |t| t.locked? }
      unlocked = @tests.select { |t| ! t.locked? }
      dir = ::IOCheck::Env["dir"]

      namespace "iocheck" do
        desc( "lock all unlocked files." )
        task "lock" => unlocked.map { |t| "iocheck:lock:#{t.name}" }
        unlocked.each do  |t|
	  namespace "lock" do
	    task t.name do
	      dest = dir + "/" + "lock"
	      mv ::IOCheck.readfile(t.name), dest
            end
	  end
        end
        desc( "unlock all locked files." )
	task "unlock" => locked.map { |t| "iocheck:unlock:#{t.name}" }
	locked.each do |t|
          namespace "unlock" do
	    task t.name do
	      dest = dir + "/" + "unlock"
	      mv ::IOCheck.readfile(t.name), dest
	    end
	  end
	end
      end
    end

  private
    def show
      @tests.each do |t|
        t.show
      end
      puts
      show_overall
    end

    def show_overall
      n_success = 0
      n_failure = 0
      @tests.each do |t|
        if t.succeeded?   
          n_success += 1
        else
	  n_failure += 1
        end
      end
      puts "--------------"
      puts "Overall Result"
      puts "Success : #{n_success}"
      puts "Failure : #{n_failure}"
    end
  end # end of class Tester
end # end of module IOCheck
