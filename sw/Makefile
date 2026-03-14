CC ?= gcc
CFLAGS ?= -std=c11 -O2 -Wall -Wextra -Wpedantic
LDFLAGS ?=

TARGETS := example_driver_usage example_driver_irq_usage
COMMON_SRCS := mipi_csi2_axi.c

.PHONY: all clean

all: $(TARGETS)

example_driver_usage: example_driver_usage.c $(COMMON_SRCS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

example_driver_irq_usage: example_driver_irq_usage.c $(COMMON_SRCS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

clean:
	rm -f $(TARGETS)
