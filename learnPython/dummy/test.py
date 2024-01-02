a = 10
list = [10,20,30,40] 
print(a)
print(list)
# list=a
# print(list)
list[2] = a
print(list)

def calculateMarks(myMarks):
    myMarks[2] = 70

marks = [30,56,89,48,76]
calculateMarks(marks)
print(marks)

def calculateMarks(myMarks):
    myMarks = [70,654,5,654,]

marks = [30,56,89,48,76]
calculateMarks(marks)
print(marks)

def lnum(num):
    num=20
    return num
num=10
print(lnum(num))
print(num)

def multi(*num):
    mul=1
    for i in num:
        mul=mul*i
    return mul

print(multi(1,2,3,4))

def multi(var,*num):
    mul=var
    for i in num:
        mul=mul*i
    return mul

print(multi(10,1,2,3,3,4))

def bd(**kwargs):
    for x,y in kwargs.items():
        print('{}: {}'.format(x,y))
bd(colour='green',cap='1')

def fr(app,bana,gra):
    print(app,bana,gra)
fru=[1,3,5]
fr(*fru)

def coconutCap(value):
    cal=value*2
    yield cal
    print('xcellent')
cal=coconutCap(3)
for i in cal:
    print(i)