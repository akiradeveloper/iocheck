# iocheck

## Motivation "Make Refactoring Safe."
There are thousand of softwares without test codes and 
you do not have much time to add test programs to the software which disrespectively called legacy.
Some kind of softwares, such as visualization softwares, are hard to test and these softwares are usually left untested.

iocheck is in the opposite side of QuickCheck, a Haskell de-facto standard testing framework for purely functional codes.  
Instead of checking the pure property of the softwares like QuickCheck does,
iocheck checks the standard output with which any kind of programming languages equip.

iocheck helps engineers working on legacy softwares who wants to refactor these software safely.
If the software is written in COBOL or Fortran, it is OK. There is a hope called iocheck.
All you have to do is write a main program to
give some states of the program running to standard output,
create test file, refactor a little bit and run iocheck to make sure no behavior changed.

In summery, standard IO is equipped with any kind of languages even if they are almost out-dated.
With iocheck testing framework, you can test legacy softwares usually written in those languages
without any learning cost.

## Installation
iocheck can be installed from rubygems repository, just type

```bash
gem install iocheck
```

## Contributing to iocheck
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright
Copyright (c) 2011 Akira Hayakawa (@akiradeveloper). See LICENSE.txt for
further details.

