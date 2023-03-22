print("BMI Calculator")

weight = int(input("Enter weight in pounds: "))

height = int(input("Enter height in inches: "))

BMI = (weight * 703) / (height * height)

print(round(BMI,2))

if BMI>0: 
    if(BMI<18.5):
        print("You are underweiht.")
    elif(BMI<25):
        print("You are normal weight.")
    elif(BMI<30):
        print("You are overweight.")
    elif(BMI<35):
        print("You are obese.")
    elif(BMI<40):
        print("You are severely obese.")
    elif(BMI>40):
        print("You are morbidly obese.")    
else:
    print("Invalid input.")
