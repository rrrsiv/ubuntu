########### Data Types ###############
# Numeric-----> int,float,complex,
# Sequence----> strings,list,tuple
# Boolean-----> True, Flase
# Set
# Dictionary
#########
#Mutable----which can be change
#immutable---which can't be change
#Hashable----which also cnat change
####### NUMERIC(INT,FLOAT,COMPLEX) ############
totalMarks = 600
obtainedMarks = int(input('Enter Your Marks'))
percentage = (obtainedMarks/totalMarks)*100
print('Your Percentage is',percentage)
a = 3 + 2j
print(type(a),a.real,a.imag,a.conjugate())

##############Sequence( strings,list,tuple )######################
#STRINGS are immutable
name = 'ramani sivakumar'
print(type(name))
#Accessing the charcters in a string using indexing and slicing(will print set of charcters)
print(name[0]) #will print r
print(name[6]) #will print space
print(name[2:5]) #will print man.By default it includes staring char and exclude ending char with default step 1
print(name[-1]) #will print last char
print(name[::-1]) #will print reverse
print(name[-1:-7:-1]) #will print set of chars in reverse
# we cant delete or update the characters in a string
print('a' in name) #will print true cuase a is available in the string
print('z' not in name) #will print true cuase z is not available in the string

######### List
'''holds different types of data
mutable
order of items cant change
allows duplicate data
items are placded in [] and separated by ,(comma)
update/delete/remove is possible'''
print('Programme on list datatype')
list = ['siva', 'kavi', 'abhi', 'abhay', 29, 27, 1, 1]
print(list)
print(len(list))
print(list[0:2])
print(list[2])
print(list[::-1])
print(list[-4::-1])
for x in list:
    print(x)
