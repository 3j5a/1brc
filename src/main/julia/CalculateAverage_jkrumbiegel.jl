using Mmap
using InlineStrings
using Dictionaries
using Parsers

function aggregate(file)
    open(file, "r") do io
        arr = mmap(io)
    
        len = length(arr)
        nthreads = 8

        chunkstarts = round.(Int, range(1, len, length = nthreads + 1))[1:end-1]
        
        for i in 2:length(chunkstarts)
            chunkstarts[i] = findnext(==(UInt8('\n')), arr, chunkstarts[i]) + 1
        end
        chunkends = [chunkstarts[2:end] .+ 1; len]

        dicts = Vector{Dictionary{String31, Tuple{Int,Float64,Float64,Float64}}}(undef, nthreads)

        Threads.@threads for i in 1:nthreads
            dicts[i] = kernelfunc(arr, chunkstarts[i], chunkends[i])
        end

        d = dicts[1]
        for id in 2:nthreads
            for (key, value) in pairs(dicts[id])
                if haskey(d, key)
                    existing = d[key]
                    d[key] = map((f, a, b) -> f(a, b), (+, +, min, max), existing, value)
                else
                    insert!(d, key, value)
                end
            end
        end
        print("{")
        isfirst = true
        for (city, (n, _sum, _min, _max)) in pairs(sortkeys(d))
            if isfirst
                isfirst = false
            else
                print(", ")
            end
            print(city, "=", _sum/n, "/", _min, "/", _max)
        end
        print("}")
        return d
    end
    println()
end

function kernelfunc(arr, start, stop)
    d = Dictionary{String31, Tuple{Int,Float64,Float64,Float64}}()
    startword = start
    while startword <= stop
        i_delim = findnext(==(UInt8(';')), arr, startword)::Int
        newline = findnext(==(UInt8('\n')), arr, i_delim + 1)::Int
        s = String31(arr, startword, i_delim - startword)

        val = Parsers.xparse(Float64, arr, i_delim + 1, newline - 1).val::Float64

        hadtoken, token = gettoken!(d, s)
        if hadtoken
            n, _sum, _min, _max = gettokenvalue(d, token)
        else
            n = 0
            _sum = 0.0
            _min = Inf
            _max = -Inf
        end
        n += 1
        _sum += val
        _min = min(_min, val)
        _max = max(_max, val)

        settokenvalue!(d, token, (n, _sum, _min, _max))

        startword = newline + 1
    end
    return d
end

aggregate("./measurements.txt")