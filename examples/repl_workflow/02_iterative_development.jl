# =============================================================================
# Example 2: Iterative Development Workflow
# =============================================================================
# This file demonstrates how to iteratively develop and refine functions
# using the REPL integration.
#
# Workflow:
# 1. Write initial version of function
# 2. Send to REPL (shift-enter)
# 3. Test in REPL
# 4. Find issues, edit function
# 5. Send updated version to REPL (shift-enter)
# 6. Test again
# 7. Repeat until satisfied
#
# =============================================================================

# VERSION 1: Initial implementation (has a bug!)
function fibonacci(n)
    if n <= 1
        return n
    end
    return fibonacci(n - 1) + fibonacci(n - 2)
end

# Try it: fibonacci(5)
# Works! But try: fibonacci(35)  # Very slow!

# VERSION 2: Add memoization (still not perfect)
fib_cache = Dict{Int, Int}()

function fibonacci_memo(n)
    if n <= 1
        return n
    end

    if haskey(fib_cache, n)
        return fib_cache[n]
    end

    result = fibonacci_memo(n - 1) + fibonacci_memo(n - 2)
    fib_cache[n] = result
    return result
end

# Try it: fibonacci_memo(35)  # Much faster!
# But problem: fib_cache persists between calls and grows

# VERSION 3: Better memoization with function argument
function fibonacci_cached(n, cache=Dict{Int,Int}())
    if n <= 1
        return n
    end

    if haskey(cache, n)
        return cache[n]
    end

    cache[n] = fibonacci_cached(n - 1, cache) + fibonacci_cached(n - 2, cache)
    return cache[n]
end

# Try it: fibonacci_cached(35)  # Fast and clean!

# VERSION 4: Iterative approach (even better!)
function fibonacci_iter(n)
    if n <= 1
        return n
    end

    prev, curr = 0, 1
    for i in 2:n
        prev, curr = curr, prev + curr
    end
    return curr
end

# Try it: fibonacci_iter(100)  # Works for much larger numbers!

# =============================================================================
# Real-world example: Processing data
# =============================================================================

# VERSION 1: Basic implementation
function process_data(data)
    result = []
    for item in data
        push!(result, item * 2)
    end
    return result
end

# Test: process_data([1, 2, 3, 4, 5])

# VERSION 2: More functional approach
function process_data_v2(data)
    return map(x -> x * 2, data)
end

# Test: process_data_v2([1, 2, 3, 4, 5])

# VERSION 3: Make it generic
function process_data_v3(data, operation)
    return map(operation, data)
end

# Test: process_data_v3([1, 2, 3, 4, 5], x -> x * 2)
# Test: process_data_v3([1, 2, 3, 4, 5], x -> x^2)

# VERSION 4: Add filtering
function process_and_filter(data, operation, predicate)
    processed = map(operation, data)
    return filter(predicate, processed)
end

# Test: process_and_filter([1, 2, 3, 4, 5], x -> x * 2, x -> x > 5)

# =============================================================================
# Benchmarking workflow
# =============================================================================
# After developing, benchmark your functions!

# First, install BenchmarkTools in REPL:
# using Pkg; Pkg.add("BenchmarkTools")

# Then load it:
# using BenchmarkTools

# Benchmark commands to send (one at a time):
# @benchmark fibonacci(20)
# @benchmark fibonacci_memo(20)
# @benchmark fibonacci_cached(20)
# @benchmark fibonacci_iter(20)

# You'll see that fibonacci_iter is the fastest!
