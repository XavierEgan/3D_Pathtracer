# Compiler and flags
CC = gcc
CFLAGS = -Wall -g -mavx

# Target executable
TARGET = 3d_raytracer

# Source and object files
SRCS = main.c render.c \
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
