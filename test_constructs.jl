# Test file for verifying textobject selections
# This file contains various Julia constructs to test our textobjects.scm

# 1. Simple function
function simple_func()
    return 42
end

# 2. Short function definition
short_func(x) = x^2

# 3. Function with arguments
function with_args(x::Int, y::String)
    println(y, x)
end

# 4. Macro definition
macro test_macro(expr)
    return esc(expr)
end

# 5. Struct
struct MyStruct
    field1::Int
    field2::String
end

# 6. Module
module TestModule
    export test_func

    function test_func()
        println("test")
    end
end

# 7. Begin/end block
result = begin
    x = 10
    y = 20
    x + y
end

# 8. Let block
let x = 1, y = 2
    x + y
end

# 9. Quote block
expr = quote
    x = 1
    y = 2
end

# 10. Do block
map(1:5) do x
    x^2
end

# 11. If statement
if true
    println("yes")
elseif false
    println("maybe")
else
    println("no")
end

# 12. For loop
for i in 1:10
    println(i)
end

# 13. While loop
while false
    println("never")
end

# 14. Try-catch
try
    error("test")
catch e
    println("caught: ", e)
finally
    println("cleanup")
end

# 15. Test blocks (commented out until we verify the grammar)
# @testset "Basic tests" begin
#     @test 1 + 1 == 2
#     @test true
# end

# 16. Nested functions
function outer()
    function inner()
        return 1
    end
    return inner()
end

# 17. Abstract type
abstract type AbstractFoo end

# 18. Primitive type
primitive type MyInt8 8 end
