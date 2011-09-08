# Design and API
First of all, please visit sample/ and understand what can be done by iocheck.

This document explains the design concept of iocheck and
furthur API to make use of iocheck.

## Lock and Unlock
It is very typical for iocheck users to lock the generated standard output to refactor your source code.

iocheck categorizes files in two kinds. One is called "lock" and the another is called "unlock".

Files in lock are never updated, if you do ```rake iocheck:update``` while those in unlock are.
iocheck prioritizes those in lock, if it finds same files in both lock and unlock,
it will never update the unlock one and everlastingly use one in lock.

To safely manipulate the files between lock and unlock, iocheck provides ```rake iocheck:lock:hoge``` task
which locks file named "hoge". If you want to lock all the files at the same time, you can use ```rake iocheck:lock``` task.
unlock is also given.

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
  # Expected -> Actual -> Either in Haskell notation.
  def evaluate(expected, actual)
    # returns IOCheck::Policy::Either
  end
end

your_policy = YourPolicy.new
```

or use skeltal implementation that you can pass a block

```ruby
your_policy = IOCheck::Policy::Block do |expected, actual|
  # returns IOCheck::Policy::Either
end
```

and finally,

```ruby
tester << test.by(your_policy)
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
