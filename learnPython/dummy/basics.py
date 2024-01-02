print("hello boy, start learning python")
a = 200
b = 100 
c = 600 
d = 40 
total=a+b+c+d
print(total)
############## Input and Output #################
varOne="in learning python"
var1="keep focus on learning"
print('hey siva, you are doing good',varOne,',',var1)

###### Operators ################
a = 10
b = 7
add = a+b
sub = b-a
mul = a*b
div = b/a
flo = a//b
pow = a**b
rem = a%b
print('addition',add,'substraction',sub,'multiplication',mul,'division',div,'floor',flo,'power',pow,'remainder',rem)
######## Relational operators ####################
print(a==b,a>b,a<b,a>=b,a<=b,a!=b)
print(a and b,a or b,not a,not b,c and d)
########## find age of the persion by asking birth year ##############
from datetime import date
currentYear = date.today().year
birthYear = input('Enter Birth Year')
by = int(birthYear)
age = currentYear-by
print('Age is',age)
