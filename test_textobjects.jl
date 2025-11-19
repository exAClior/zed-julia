# Test file for textobjects

# Regular function definition
function regular_function(x, y)
    z = x + y
    return z * 2
end

# Short function definition
short_func(a, b) = a * b + 1

# Function with typed parameters
function typed_func(x::Int, y::Float64)::Float64
    return x + y
end

# Function with optional parameters
function optional_func(x, y=10)
    return x + y
end

# Function with keyword parameters
function keyword_func(x; verbose=false, max_iter=100)
    if verbose
        println("Running with max_iter=$max_iter")
    end
    return x
end

# Macro definition
macro my_macro(expr)
    return :(println($expr))
end

# Struct definition
struct Point
    x::Float64
    y::Float64
end

# Mutable struct
mutable struct MutablePoint
    x::Float64
    y::Float64
end

# Abstract type
abstract type AbstractShape end

# Primitive type
primitive type MyInt8 8 end

# Parametric struct
struct Container{T}
    value::T
end

# Module definition
module MyModule
    export my_function

    function my_function(x)
        return x + 1
    end
end

# For loop
function loop_example()
    sum = 0
    for i in 1:10
        sum += i
    end
    return sum
end

# While loop
function while_example()
    i = 0
    while i < 10
        i += 1
    end
    return i
end

# If-else conditional
function conditional_example(x)
    if x > 0
        return "positive"
    elseif x < 0
        return "negative"
    else
        return "zero"
    end
end

# Begin-end block
function block_example()
    result = begin
        a = 1
        b = 2
        a + b
    end
    return result
end

# Let block
function let_example()
    x = let
        a = 10
        b = 20
        a + b
    end
    return x
end

# Quote block
function quote_example()
    ex = quote
        x = 1
        y = 2
        x + y
    end
    return ex
end

# Function calls
function call_example()
    result1 = println("hello")
    result2 = sin(π/2)
    result3 = max(1, 2, 3)
end

# Macro calls
function macro_call_example()
    @time begin
        sleep(0.1)
    end
end

# Broadcast calls
function broadcast_example()
    arr = [1, 2, 3]
    result = sin.(arr)
    return result
end

# Tests
using Test

@test 1 + 1 == 2

@test_throws DivideError 1 ÷ 0

@testset "Math tests" begin
    @test 2 + 2 == 4
    @test 3 * 3 == 9
end

# Comments
# This is a single line comment

#=
This is a
multi-line block
comment
=#

# Tuples
function tuple_example()
    t1 = (1, 2, 3)
    t2 = (a=1, b=2, c=3)
    return t1, t2
end

# Arrays/Vectors
function array_example()
    v1 = [1, 2, 3, 4, 5]
    v2 = [x^2 for x in 1:5]
    return v1, v2
end
