# Compiler and flags
CC = gcc
CFLAGS = -Wall -g -mavx -lpthread -O3 #-O3 or -Og

# Target executable
TARGET = d

# Source and object files
SRCS = main.c render.c fancy_loading_bar.c\
	math/Tri.c math/Vec3.c \
	definitions/camera.c definitions/framebuffer.c definitions/mesh.c

OBJS = $(SRCS:.c=.o)

# Default target
all: $(TARGET)

# How to build the target
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS)

# How to compile .c files to .o files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Clean up
clean:
	rm -f $(OBJS) $(TARGET)
