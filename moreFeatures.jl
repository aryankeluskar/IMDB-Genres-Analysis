# Structs
"IMMUTABLE STRUCTS"
struct firstStruct
    field1
    field2
end
myObj1 = firstStruct("Hello", "World")
println(myObj1)

"MUTABLE STRUCTS"
# can be used as objects; structs are like blueprinf
mutable struct Person
    name::String
    age::Int16
    isAlive
end

"CONSTRUCTORS"
function Person(name, age)
    new(name, age, true)
end
function addToEvent(person::Person)
    if(person.age>18)
        println("Welcome!")
    end
end
julia = Person("Julia", 19)
julia.age+=1
println(julia)
addToEvent(julia)


# Multiple methods for the operator +
"println(methods(+))"

# use @which to determine which method is being dipatched
"which(+, 3.0+2)"