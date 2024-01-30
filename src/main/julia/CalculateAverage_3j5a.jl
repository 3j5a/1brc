mutable struct MeasurementsStats
    min::Float32; max::Float32; sum::Float64; count::Int64
end

roundjava(it, digits) = round(it, RoundNearestTiesUp; digits = digits)
roundjava(it) = roundjava(it, 1)

function calculate_average(measurements)
    station_measurements = Dict{String, MeasurementsStats}()    
    open(measurements, "r") do file
        for measurement in eachline(file)
            station, temperature = split(measurement, ";")
            temperature = parse(Float32, temperature)
            if haskey(station_measurements, station)
                station_stats = station_measurements[station]
                station_stats.min = min(station_stats.min, temperature)
                station_stats.max = max(station_stats.max, temperature)
                station_stats.sum += temperature
                station_stats.count += 1
            else
                station_measurements[station] = MeasurementsStats(temperature, temperature, temperature, 1)
            end        
        end
    end
    results::Vector{Any} = collect(station_measurements)
    sort!(results, by = it -> it[1])
    map!(results, results) do (station, stats)
         average = roundjava(stats.sum/stats.count, 2)
        "$station=$(roundjava(stats.min))/$(roundjava(average))/$(roundjava(stats.max))"
    end        
    println("{", join(results, ", "), "}")                  
end

calculate_average(isempty(ARGS) ? "./measurements.txt" : ARGS[1])