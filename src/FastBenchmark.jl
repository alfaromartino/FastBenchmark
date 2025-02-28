module FastBenchmark

using Chairmarks

function mybenchmark_implementation(expr)
    # Capture the Chairmarks module in a QuoteNode so that it's available
    # in the generated code independently of the caller's scope.
    local cm = QuoteNode(Chairmarks)
    return quote
        # Bind the captured module to a local variable.
        local _cm = cm
        # Use the Chairmarks macro via the captured module reference.
        object = _cm.@b (expr)
        result = sprint(show, "text/plain", object)

        if object.allocs == 0
            result *= " (0 allocations: 0 bytes)"
        else
            result = replace(result, "allocs" => "allocations")
        end

        # Remove any other information that comes after the allocations if it exists        
        #result = replace(result, r",(?![^,]*\bgc\b).*$" => "")     # to keep gc time
        result = replace(result, r",.*$" => ")")                   # to get rid of everything
        result = replace(result, "(without a warmup) " => "")

        println("  " * result)  # Add two spaces before the result
    end

end

macro ctime(expr)
    # We return the quoted code as-is since it already captures Chairmarks.
    return mybenchmark_implementation(expr)
end

export @ctime
end # module FastBenchmark