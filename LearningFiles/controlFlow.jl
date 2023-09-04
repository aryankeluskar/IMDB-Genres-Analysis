# Loops, Conditionals, Functions    

# Functions
function multiply(a, b)
    println(a*b)
end

multiply(10, 100)

# While Loop
i=0
while i>10
    println(i)
    local i+=1
end

# For Loop
j=0
for j in 10:39
    println(j)
    local j+=2
end

# Conditionals
a=parse(Int64,readline())
b=parse(Int64, readline())
if a>b
    println("$a is greater than $b")
end
(a>b) && println("$a is greater than $b")
(a<b) && println("$a is smaller than $b")