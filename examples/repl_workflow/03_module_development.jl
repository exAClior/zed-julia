# =============================================================================
# Example 3: Module Development Workflow
# =============================================================================
# This file demonstrates developing Julia modules with REPL integration.
#
# Workflow:
# 1. Define module with functions
# 2. Send entire module to REPL (vac to select, shift-enter)
# 3. Test module functions
# 4. Edit module as needed
# 5. Re-send to REPL to update
#
# For production: Use Revise.jl for automatic reloading
# =============================================================================

# Simple module with basic functionality
module MathUtils
    export double, triple, quadruple
    export is_even, is_odd

    # Public functions
    double(x) = 2x
    triple(x) = 3x
    quadruple(x) = 4x

    is_even(n) = n % 2 == 0
    is_odd(n) = !is_even(n)

    # Private function (not exported)
    internal_helper(x) = x + 1
end

# Try it:
# 1. Select entire module (vac), shift-enter
# 2. In REPL: using .MathUtils
# 3. Test: double(5), is_even(4)

# More complex module with types
module Geometry
    export Point, Circle, Rectangle
    export area, perimeter, translate

    # Define types
    struct Point
        x::Float64
        y::Float64
    end

    struct Circle
        center::Point
        radius::Float64
    end

    struct Rectangle
        corner::Point
        width::Float64
        height::Float64
    end

    # Generic functions
    translate(p::Point, dx, dy) = Point(p.x + dx, p.y + dy)

    # Circle-specific functions
    area(c::Circle) = π * c.radius^2
    perimeter(c::Circle) = 2π * c.radius

    # Rectangle-specific functions
    area(r::Rectangle) = r.width * r.height
    perimeter(r::Rectangle) = 2 * (r.width + r.height)
end

# Try it:
# using .Geometry
# p = Point(0.0, 0.0)
# c = Circle(p, 5.0)
# r = Rectangle(p, 10.0, 20.0)
# println("Circle area: ", area(c))
# println("Rectangle area: ", area(r))

# Module with nested modules
module DataProcessing
    export Statistics, Filters, transform_data

    module Statistics
        export mean, median, std_dev

        function mean(data)
            return sum(data) / length(data)
        end

        function median(data)
            sorted = sort(data)
            n = length(sorted)
            if n % 2 == 0
                return (sorted[n÷2] + sorted[n÷2 + 1]) / 2
            else
                return sorted[(n+1)÷2]
            end
        end

        function std_dev(data)
            μ = mean(data)
            return sqrt(sum((x - μ)^2 for x in data) / length(data))
        end
    end

    module Filters
        export remove_outliers, remove_missing, normalize

        function remove_outliers(data, threshold=2.0)
            μ = sum(data) / length(data)
            σ = sqrt(sum((x - μ)^2 for x in data) / length(data))
            return filter(x -> abs(x - μ) < threshold * σ, data)
        end

        remove_missing(data) = filter(!isnan, data)

        function normalize(data)
            min_val, max_val = minimum(data), maximum(data)
            return [(x - min_val) / (max_val - min_val) for x in data]
        end
    end

    function transform_data(data, transformers...)
        result = data
        for transformer in transformers
            result = transformer(result)
        end
        return result
    end
end

# Try it:
# using .DataProcessing
# using .DataProcessing.Statistics
# using .DataProcessing.Filters
# data = [1.0, 2.0, 3.0, 100.0, 4.0, 5.0]
# println("Mean: ", mean(data))
# println("Median: ", median(data))
# cleaned = remove_outliers(data)
# println("After removing outliers: ", cleaned)
# normalized = normalize(cleaned)
# println("Normalized: ", normalized)

# =============================================================================
# Workflow with Revise.jl (for production development)
# =============================================================================
# For real package development, use Revise.jl:
#
# 1. Install Revise:
#    using Pkg; Pkg.add("Revise")
#
# 2. In REPL startup (before loading your package):
#    using Revise
#
# 3. Load your package:
#    using MyPackage
#
# 4. Now edit any file in MyPackage and save
#    Changes are automatically reflected in the REPL!
#
# 5. No need to send code manually - Revise watches for changes
#
# For this workflow file:
# - Send module definitions manually for quick experiments
# - Use Revise for serious package development
# =============================================================================

# Example module that works well with Revise
module Calculator
    export add, subtract, multiply, divide
    export calculate

    add(a, b) = a + b
    subtract(a, b) = a - b
    multiply(a, b) = a * b
    divide(a, b) = b != 0 ? a / b : error("Division by zero")

    function calculate(operation, a, b)
        ops = Dict(
            :add => add,
            :subtract => subtract,
            :multiply => multiply,
            :divide => divide
        )

        if !haskey(ops, operation)
            error("Unknown operation: $operation")
        end

        return ops[operation](a, b)
    end
end

# With Revise:
# 1. Send module once
# 2. Edit any function (e.g., add error handling to divide)
# 3. Save file
# 4. Changes are live in REPL!
# 5. Test immediately without re-sending

# Test:
# using .Calculator
# calculate(:add, 5, 3)
# calculate(:multiply, 4, 7)
# calculate(:divide, 10, 2)
