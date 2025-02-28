module FastBenchmark

using Chairmarks

function mybenchmark_implementation(expr)
    quote
        object = Chairmarks.@b $(expr)
        result = sprint(show, "text/plain", object)
        
        if object.allocs == 0
            result *= " (0 allocations: 0 bytes)"
        else
            result = replace(result, "allocs" => "allocations")
        end
        
        # Remove any other information that comes after the allocations if it exists        
        #result = replace(result, r",(?![^,]*\bgc\b).*$" => "")     # to keep gc time
        result  = replace(result, r",.*$" => ")")                   # to get rid of everything
        result  = replace(result, "(without a warmup) " => "")

        println("  " * result)  # Add two spaces before the result
    end
end

macro ctime(expr)
    return esc(mybenchmark_implementation(expr))
end

export @ctime

end
