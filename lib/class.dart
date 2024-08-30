import 'dart:io';

class Calculator {
  // Instance variables to store the numbers
  int? num1;
  int? num2;

  // Function to add the numbers
  int addNumbers(int num1, int num2) {
    // Assign the passed numbers to the instance variables
    this.num1 = num1;
    this.num2 = num2;

    // Return the sum
    return num1 + num2;
  }

  // Function to access num1 and num2
  String hey() {
    print(this.num1);
    print(this.num2);
    return 'ok';
  }
}

void main() {
  // Create an instance of the Calculator class
  Calculator calculator = Calculator();

  int? num1 = int.parse(stdin.readLineSync()!);
  int? num2 = int.parse(stdin.readLineSync()!);
  // Call the addNumbers function
  calculator.addNumbers(num1, num2);
  calculator.hey();

  Calculator newCalc = Calculator();
  newCalc.addNumbers(8, 9);
  newCalc.hey();

  // Call the hey function to access num1 and num2
  print(calculator.hey()); // Output: The numbers are 5 and 10.
}
