# Design and API
First of all, please visit sample/ and understand what can be done by iocheck.

## Policy

### What is Policy?
Policy is an evaluator.
The result of a command ran is evaluated by possibly multiple policies.
For example,
a policy sees the matching of data in exact byte sequence and 
an another policy sees the command finished within one second.

Policy is an abstraction to let the user-defined evaluator
like matching a human face and an another human face ambiguously.  
And an other example is a figure generated can be evaluated equal to another figure
considering the randomness in their generation. This is typical in visualization case
which is usally hard to test by traditional testing framework.

### Use your original policy functor.

```ruby
class YourPolicy < IOCheck::Policy
  def initialize
    super
  end
  # Expected class and Actual class
  def evaluate(expected, actual)
    # returns Bool
  end
end

your_policy = YourPolicy.new
```
or use skeltal implementation which must be given block

```ruby
your_policy = IOCheck::Policy::Block do |expected, actual|
  # returns Bool
end
```

and finally,

```
tester << test.by(yourpolicy).hoge
```

as in sample/ .

## Configurations

### Change the directory for iocheck files.
If you want to use other directory instead of iocheck/.  
This is typically useful if the directory is tempfs in some other location.

```ruby
yourdir = "/mnt/tempfs"
IOCheck::Env["dir"] = yourdir
```
