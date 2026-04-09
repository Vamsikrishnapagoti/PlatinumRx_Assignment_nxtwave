minutes = int(input("Enter minutes: "))

hours = minutes // 60
remaining_minutes = minutes % 60

if hours == 1:
    print(f"{hours} hr {remaining_minutes} minutes")
else:
    print(f"{hours} hrs {remaining_minutes} minutes")
