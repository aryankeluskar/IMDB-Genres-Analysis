println("Hello World")

my_var = 56
println(typeof(my_var))

💀 = "$my_var is a number"
println(💀)

# Single Line
🌙 = """"moonlight" is beautiful, isnt it <3"""
println(🌙)

#=
And this a multi-line comment
=#

println(convert(Int, round(3.121212)))
println(convert(Float64, round(3.121212)))


# Dictionaries - IMMUTABLE
first_book = Dict("Aryan K"=> 602973042)
println(first_book)

first_book["Kremlin"]=3897032 #Inserting
println(first_book)

# Tuples - IMMUTABLE, INDEXED
first_tuple = ("first", "second", "third") # Begins with Index 1
println(first_tuple[1])

# Array - MUTABLE, INDEXED
first_array = ["first", "second", "third", 56, 90.1, true] # Begins with Index 1
println(first_tuple)
push!(first_array, 2)
println(first_array)
pop!(first_array)
println(first_array)

# Random Arrays
println(rand(4, 3, 5))