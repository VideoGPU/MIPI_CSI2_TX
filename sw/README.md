# Software Driver Example (`sw/`)

This folder contains a minimal C driver for the AXI4-Lite control interface added in `hdl/fmc_mipi_top.vhd`.

Files:
- `mipi_csi2_axi.h`: register map, bit definitions, API
- `mipi_csi2_axi.c`: MMIO-based driver implementation
- `example_driver_usage.c`: polling-style start/IRQ/stop usage example
- `example_driver_irq_usage.c`: IRQ-oriented usage flow with BSP hook stubs
- `Makefile`: build helper for both example programs

## Quick usage

1. Set your AXI-Lite base address in examples.
2. Optionally update stream/timing config fields in `mipi_csi2_config_t`.
3. Build:
- `make -C sw`
4. Run your preferred flow:
- polling (`example_driver_usage`):
- `mipi_csi2_apply_config(...)`
- `mipi_csi2_start(...)`
- wait for `mipi_csi2_irq_pending(...)`
- `mipi_csi2_clear_irq(...)`
- `mipi_csi2_request_stop(..., true)`
- IRQ (`example_driver_irq_usage`):
- register ISR callback with your platform IRQ controller
- enable IRQs
- call `mipi_csi2_start(...)`
- clear pending inside ISR with `mipi_csi2_clear_irq(...)`

## Notes

- `CONTROL` writes update bits `[5:1]` in hardware, so the driver always does read-modify-write for `start`, `stop`, and IRQ clear.
- `start` is a pulse command (bit0). The hardware commits synchronized runtime config at start edge.
- The MMIO helpers in `mipi_csi2_axi.c` are generic; replace with your BSP primitives if needed.
