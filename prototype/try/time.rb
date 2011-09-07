require "benchmark"

if __FILE__ == $0
  r = `(time tree ~/code > /dev/null) 2>&1`
  #rp r.split

  Benchmark.bm do |x|
    x.report("akira", 100, "%10.6u %y %U %Y %t %rh%n\r") { 100**100000 }
  end
end
