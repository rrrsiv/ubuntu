'''Rank = int(input("Enter your EAMCET rank "))
if Rank <= 1000:
    print("you are allotted to clg1")
elif Rank > 1000 and Rank <= 10000:
    print("You are allotted to clg2")
elif Rank > 10000 and Rank <= 30000:
    print("you are allotted to clg3")
else:
    print("Sorry, you are not allotted to any clg")'''
# name = input("Enter name ")
# caharacters = name[-2:]
# for i in range(1,11):
#     print(i*caharacters)
# vowels = ["a","e","i","o","u"]
# for i in name:
#     if i in vowels:
#         print("there is a vowel in name.The vowel is", i)
#         break
marks = [1,3,4,5,6]
total = 0
for i in marks:
    total = total + i
print(total)

