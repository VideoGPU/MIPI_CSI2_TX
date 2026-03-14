#include "mipi_csi2_axi.h"

/*
 * Platform hook examples. Replace these with your BSP/RTOS functions.
 */
static void delay_cycles(volatile uint32_t n)
{
    while (n--) {
        __asm__ volatile ("nop");
    }
}

int main(void)
{
    mipi_csi2_axi_t csi = {
        .base_addr = (uintptr_t)0x43C00000u, /* Example AXI-Lite base address */
    };

    mipi_csi2_config_t cfg;
    mipi_csi2_get_default_config(&cfg);

    /* Customize runtime stream parameters from software. */
    cfg.n_mipi_lanes = 4u;
    cfg.pixels_per_line = 3240u;
    cfg.n_lines = 1944u;
    cfg.data_type = MIPI_CSI2_DT_RAW10;
    cfg.vc = 0u;
    cfg.irq_enable = true;
    cfg.legacy_trigger_enable = false;  /* SW-only start/stop */
    cfg.debug_overlay_enable = true;

    mipi_csi2_apply_config(&csi, &cfg);

    /* Start one frame/sequence with current committed config. */
    mipi_csi2_start(&csi);

    /* Poll for frame done/IRQ pending (simple bring-up style). */
    while (!mipi_csi2_irq_pending(&csi)) {
        delay_cycles(1000u);
    }

    /* Ack interrupt in hardware. */
    mipi_csi2_clear_irq(&csi);

    /* Request graceful stop. */
    mipi_csi2_request_stop(&csi, true);

    /* Optional: clear stop request after receiver/pipeline settles. */
    delay_cycles(10000u);
    mipi_csi2_request_stop(&csi, false);

    return 0;
}
