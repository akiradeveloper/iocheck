if __FILE__ == $0
  r = `(time tree ~/code > /dev/null) 2>&1`
  p r.split
end
