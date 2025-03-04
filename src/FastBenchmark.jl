module FastBenchmark

using Chairmarks

function interpolate_node!(ex, mod)
    if ex isa Expr
        if ex.head == :$
            # Evaluate the expression in the caller's module
            value = Core.eval(mod, ex.args[1])
            return value
        else
            # Recurse into subexpressions
            for i in eachindex(ex.args)
                ex.args[i] = interpolate_node!(ex.args[i], mod)
            end
        end
    end
    return ex
end

function mybenchmark_implementation(expr, mod)
    # Interpolate variables marked with $ in the caller's module
    interpolated_expr = interpolate_node!(copy(expr), mod)
    return quote
        object = Chairmarks.@b $(esc(interpolated_expr))
        result = sprint(show, "text/plain", object)

        if object.allocs == 0
            result *= " (0 allocations: 0 bytes)"
        else
            result = replace(result, "allocs" => "allocations")
        end
        
        # Clean up the result format
        result = replace(result, r",.*$" => ")")
        result = replace(result, "(without a warmup) " => "")

        println("  " * result)
    end
end

macro ctime(expr)
    mybenchmark_implementation(expr, __module__)
end

export @ctime

end # module
