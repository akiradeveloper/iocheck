module IOCheck

class Tester

  def initialize
    @tests = []
  end
  
  def <<(test)
    @tests << test
  end

  def open
    system "rake iocheck:open"
  end

  def run!
    @tests.each { |t| r.run! }
  end

  def show
  end

  def close
    system "rake iocheck:close"
  end
end

end # end of module IOCheck
