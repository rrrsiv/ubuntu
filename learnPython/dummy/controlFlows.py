#programe to check the number is even or odd
# number=int(input('Enter the number'))
# evenNumber=number%2

# if (evenNumber==0):
#     print("it's even number")
# else:
#     print("it's odd number")

#programe to check the number is divisable by both 2 and 4
'''number=input('Enter the number')
divisableBy2=int(number)%2
divisableBy4=int(number)%4

if (divisableBy2==0):
    if (divisableBy4==0):
        print("The number divisible by both 2 and 4")
    else:
        print("The given number is not divisible by 4")
else:
    print("The given number is not divisible by 2")'''

######## For Loop #######################

for i in range(10):
    print(i)

names = ["siva", "kavi", "pavan", "aruna"]

for i in names:
    print(i)

for i in range(1,11):
    print(i)

for i in range(100,0,-1):
    print(i)

name = input("Enter your name")
print(name[-2:])
lastTwoChar = name[-2:]
for i in range(1,11):
    print(lastTwoChar*i)



