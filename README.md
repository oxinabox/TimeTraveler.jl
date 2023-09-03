# TimeTraveler

[![Build Status](https://github.com/oxinabox/TimeTraveler.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/oxinabox/TimeTraveler.jl/actions/workflows/CI.yml?query=branch%3Amain)


**Welcome Time Traveler!**  

TimeTraveler.jl is a package designed to make your time adventures more easy and  convenient.

⚠️ Please do not add this as a dependency of your package ⚠️  
Time travel is too dangerous to put in the hands of automated systems.
Instead add it to your global environment, like Revise etc.

You should also add `using TimeTraveler` to your start-up.jl.
e.g. by adding to `~/.julia/config/startup.jl`
```julia
try
    using TimeTraveler
catch e
    @warn "Error initializing TimeTraveler" exception=e
end
```


You can not time-travel to before the machine was built.
Or more precisely, you can, but you need to know exactly when your destination is. 
You can use `@back_in_the_day` to travel to world-age provided as a `UInt64`, but you can't use `@when_freshly_loaded Package` to travel to the time of loading `Package` if that package was loaded before TimeTraveler.jl as we won't have tracked when that was.

Be aware you can not modify the past!
Which is to say you can not define new methods in old world-ages.
But you can observe it.

## Use Case

In all seriousness the intended use case of this is is for writing tests.
The ideal Test Driven Development workflow is

1. Write a test.
2. Make sure it fails.
3. Write the code so it doesn't fail.
4. Confirm the test now passes.

In practice it is often annoying to write the test before you have written the code. Sometimes it is hard to know what you need to test.
So what this package lets you do is, write the test after you have written the code, but then time travel back to before you wrote the test


## Getting started

Lets say we are fixing a bug in Foo.jl

First do
`using TimeTraveler` (if it isn't in your startup.jk),
then you go about your day by loading `Foo` and doing what ever you need to do.
Then you run into a bug in Foo, while trying to do something else.

Now go and fix that bug.
While using [Revise.jl](https://timholy.github.io/Revise.jl) so your active julia session reflects the changes you have made.
(Or if you must by reexecuting defintions manually)

Then write a test
```julia
@test Foo.foo() = 100
```
and you see that that passes

Now to go back and confirm it used to fail:
```julia
@when_freshly_loaded Foo begin
    @test foo.foo() == 100
end
```


Note: if you didn't load `Test` before loading the package then the test code may not be defined.
So you would do `@@when_freshly_loaded Test` instead to run at the time that was loaded -- if that is early enough.
If not you would have to move the `@test` outside the macro -- or inspect the result manually.
e.g.
```julia
@test 100 == @when_freshly_loaded Foo foo.foo()
```

There is also [a section in the Revise.jl docs](https://timholy.github.io/Revise.jl/stable/#Secrets-of-Revise-%22wizards%22-1) about a similar work flow, which doing this with `git stash`.


## How this works

It's worth understanding how this time machine works.
Basically julia has a notion of a _world age_.
This is incremented every time package is loaded or a new method is defined etc.
And things always run in a particular world-age, which must be after the one where they were defined. -- Its why you can't `eval` a method then call it from within the same function (`invoke_latest` bypasses this rule.).
Method specialiations remember the first and last world age they are allowed to run in.
`Base.invoke_in_world` allows a function to be called in a particular world age.