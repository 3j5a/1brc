mutable struct MeasurementsStats
    min::Float32; max::Float32; sum::Float64; count::Int64
end

roundjava(it, digits) = round(it, RoundNearestTiesUp; digits = digits)
roundjava(it) = roundjava(it, 1)

function outformat((station, stats))
     average = roundjava(10*stats.sum/stats.count)/10
    "$station=$(roundjava(stats.min))/$(roundjava(average))/$(roundjava(stats.max))"
end

function calculate_average(measurements)
    station_measurements = Dict{String,MeasurementsStats}()
    open(measurements, "r") do file
        for measurement in eachline(file)
            pos = findfirst(';', measurement)
            station = @view(measurement[1:prevind(measurement, pos)])
            temperature = parse(Float32, @view(measurement[pos+1:end]))
            stats = get!(station_measurements, station) do
                MeasurementsStats(temperature, temperature, 0, 0)
            end
            stats.min = min(stats.min, temperature)
            stats.max = max(stats.max, temperature)
            stats.sum += temperature
            stats.count += 1
        end
    end
    results = collect(station_measurements)
    sort!(results, by = it -> it[1])
    print("{")
    join(stdout, (outformat(result) for result in results), ", ")
    println("}")
end

calculate_average(isempty(ARGS) ? "./measurements.txt" : ARGS[1])