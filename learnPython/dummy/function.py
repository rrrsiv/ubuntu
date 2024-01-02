numbers = [18,19,22]

for i in numbers:
    divisableBy2 = (i%2)
    if divisableBy2==0:
        print(i,'is a even number')
    else:
        print(i,'is not a even number')
