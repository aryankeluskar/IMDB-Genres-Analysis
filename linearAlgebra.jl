A = rand(1:4, 3, 3)
B=A # same memory
C=copy(A) # diff memory

println(B, C)

