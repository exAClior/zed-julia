# =============================================================================
# Example 1: Basic Function Workflow
# =============================================================================
# This file demonstrates the basic REPL workflow with simple functions.
#
# Workflow:
# 1. Place cursor anywhere inside a function
# 2. Press shift-enter (in normal mode)
# 3. Function is sent to REPL and defined
# 4. Test the function by calling it in REPL or sending test code
#
# =============================================================================

# Simple function with no arguments
function greet()
    println("Hello, Julia!")
end

# Try it: Place cursor in function above, press shift-enter
# Then in REPL type: greet()

# Function with arguments
function greet_person(name)
    println("Hello, $name !")
end

# Try it: shift-enter on function, then in REPL: greet_person("Alice")

# Function with type annotations
function add_numbers(x::Int, y::Int)::Int
    return x + y
end

# Try it: shift-enter, then test: add_numbers(5, 3)

# Function with default arguments
function power(base, exponent=2)
    return base^exponent
end

# Try it: power(3) and power(3, 3)

# Short-form function definition
square(x) = x^2

# Try it: square(5)

# Function with multiple return values
function divrem_custom(a, b)
    quotient = div(a, b)
    remainder = rem(a, b)
    return quotient, remainder
end

# Try it: q, r = divrem_custom(17, 5)

# Anonymous function stored in variable
multiply = (x, y) -> x * y

# Try it: multiply(4, 5)

# Function that calls another function
function calculate_area(radius)
    area = π * square(radius)
    return area
end

# Try it: Make sure square() is defined first, then: calculate_area(3.0)

# =============================================================================
# Testing Your Functions
# =============================================================================
# After sending functions to REPL, test them here.
# You can send individual lines in "line mode" or select and send blocks.

# Test block (select all and shift-enter in manual selection mode)
println("Testing basic functions:")
greet()
greet_person("Julia")
println("5 + 3 = ", add_numbers(5, 3))
println("3^2 = ", power(3))
println("3^4 = ", power(3, 4))
println("square(7) = ", square(7))
q, r = divrem_custom(17, 5)
println("17 ÷ 5 = $q remainder $r")
println("4 * 5 = ", multiply(4, 5))
println("Area of circle with radius 3: ", calculate_area(3.0))
