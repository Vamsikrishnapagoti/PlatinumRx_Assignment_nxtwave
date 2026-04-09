strnig = input("Enter string: ")
result = ""

for ch in string:
    if ch not in result:
        result += ch

print("Unique string:", result)
