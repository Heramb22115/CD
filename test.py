
def check_number(n):
    if n > 0:
        print("Positive")
        return 1
    elif n < 0:
        print("Negative")
        return -1
    else:
        print("Zero")
        return 0

x = 10
total = 0

for i in range(x):
    total = total + i
    check_number(i)

if total > 50:
    print("Big total")
else:
    print("Small total")