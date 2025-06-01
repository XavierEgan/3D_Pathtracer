# Compiler and flags
CXX = g++
CXXFLAGS = -Wall -std=c++17

# Main files
MAIN_TARGET = d
MAIN_SOURCES = src/Main.cpp
MAIN_OBJECTS = $(MAIN_SOURCES:.cpp=.o)

# Target executable
TEST_TARGET = test
TEST_SOURCES = 
TEST_OBJECTS = $(TEST_SOURCES:.cpp=.o)

# This is default since its first (make is the same as make main)
main: $(MAIN_TARGET)

# How do i make TARGET?
$(MAIN_TARGET): $(MAIN_OBJECTS)
	$(CXX) -o $(MAIN_TARGET) $(MAIN_OBJECTS)

test: $(TEST_TARGET)

# How do i make TEST_TARGET?
$(TEST_TARGET): $(TEST_OBJECTS)
	$(CXX) -o $(TEST_TARGET) $(TEST_OBJECTS)

# How do i make a .o file?
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean up main
cleanm:
	rm -f $(MAIN_OBJECTS) $(MAIN_TARGET)

# Clean up test
cleant:
	rm -f $(TEST_OBJECTS) $(TEST_TARGET)

# Clean everything
clean:
	rm -f $(MAIN_OBJECTS) $(MAIN_TARGET)
	rm -f $(TEST_OBJECTS) $(TEST_TARGET)

# Tell make that these are not files and are commands
.PHONY: main test cleanm cleant clean
