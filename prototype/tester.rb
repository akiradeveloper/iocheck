require "test"

module IOCheck

  Env = {}
  Env["dir"] = "./iocheck"

  class Tester
  
    def initialize
      @tests = []
    end
    
    def <<(test)
      @tests << test
      test.tester = self
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
        task "update" => @tests.map { |t| t.taskname }
      end
      task "iocheck" do
        run!
	show
      end
    end

  private

    def show
      # TODO: This is a temporal implementation.
      @tests.each do |t|
        t.show
      end
    end

  end # end of class Tester
end # end of module IOCheck
