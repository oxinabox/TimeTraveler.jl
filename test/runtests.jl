using TimeTraveler  # must be first
using Test

using Example


@testset "TimeTraveler.jl" begin

    @assert domath(0) == 5

    # Overwrite it
    Example.domath(x::Number) = x + 100
    @test domath(0) == 100
    
    @test 5 == @when_freshly_loaded Example begin
        domath(0)
    end

     #back in present day:
    @test domath(0) == 100
end
