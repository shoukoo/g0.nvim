package main

// Add performs addition of two numbers
func Add(a, b float64) float64 {
	return a + b
}

// Subtract performs subtraction of two numbers
func Subtract(a, b float64) float64 {
	return a - b
}

// Multiply performs multiplication of two numbers
func Multiply(a, b float64) float64 {
	return a * b
}

// Divide performs division of two numbers
func Divide(a, b float64) (float64, error) {
	if b == 0 {
		return 0, ErrDivisionByZero
	}
	return a / b, nil
}

// ErrDivisionByZero is returned when attempting to divide by zero
var ErrDivisionByZero = &DivisionByZeroError{}

// DivisionByZeroError represents an error for division by zero
type DivisionByZeroError struct{}

func (e *DivisionByZeroError) Error() string {
	return "division by zero"
}
