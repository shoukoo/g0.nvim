package main

import "testing"

func TestAdd(t *testing.T) {
	result := Add(10, 5)
	expected := 15.0
	if result != expected {
		t.Errorf("Addition failed: expected %v, got %v", expected, result)
	}
}

func TestSubtract(t *testing.T) {
	result := Subtract(10, 5)
	expected := 5.0
	if result != expected {
		t.Errorf("Subtraction failed: expected %v, got %v", expected, result)
	}
}

func TestMultiply(t *testing.T) {
	result := Multiply(10, 5)
	expected := 50.0
	if result != expected {
		t.Errorf("Multiplication failed: expected %v, got %v", expected, result)
	}
}

func TestDivide(t *testing.T) {
	t.Run("Valid division", func(t *testing.T) {
		result, err := Divide(10, 5)
		if err != nil {
			t.Errorf("Expected no error, but got: %v", err)
		}
		expected := 2.0
		if result != expected {
			t.Errorf("Division failed: expected %v, got %v", expected, result)
		}
	})

	t.Run("Division by zero", func(t *testing.T) {
		_, err := Divide(10, 0)
		if err == nil {
			t.Error("Expected division by zero error, but got no error")
		}
		expected := "division by zero"
		if err.Error() != expected {
			t.Errorf("Expected error message '%s', but got '%v'", expected, err)
		}
	})
}
