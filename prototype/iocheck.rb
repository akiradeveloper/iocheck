module IOCheck

class Tester
end

class Answer
  def initialize(name)
  end
end

class Exec
  def initialize(command)
    @command = command
  end

  def name=(name)
    @name = name
  end

  def name
    if @name == nil
      return name_from_command
    end
    @name
  end
end


end # end of module IOCheck
