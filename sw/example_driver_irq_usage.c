#include "mipi_csi2_axi.h"

#include <stdbool.h>
#include <stddef.h>

/*
 * This file demonstrates an IRQ-oriented control flow.
 * Replace platform_* hooks with your BSP/RTOS interrupt API.
 */
typedef void (*irq_handler_t)(void *arg);

static volatile bool g_frame_done_irq = false;

/* Stub hooks so this file builds in a generic environment. */
static void platform_register_irq(irq_handler_t handler, void *arg)
{
    (void)handler;
    (void)arg;
}

static void platform_enable_irq(void)
{
}

static void platform_wait_for_irq_event(void)
{
    /* Placeholder wait primitive. */
    __asm__ volatile ("nop");
}

static void mipi_csi2_isr(void *arg)
{
    mipi_csi2_axi_t *dev = (mipi_csi2_axi_t *)arg;

    mipi_csi2_clear_irq(dev);
    g_frame_done_irq = true;
}

int main(void)
{
    mipi_csi2_axi_t csi = {
        .base_addr = (uintptr_t)0x43C00000u,
    };

    mipi_csi2_config_t cfg;
    mipi_csi2_get_default_config(&cfg);
    cfg.n_mipi_lanes = 2u;
    cfg.irq_enable = true;
    cfg.legacy_trigger_enable = false;

    mipi_csi2_apply_config(&csi, &cfg);

    platform_register_irq(mipi_csi2_isr, &csi);
    platform_enable_irq();

    g_frame_done_irq = false;
    mipi_csi2_start(&csi);

    while (!g_frame_done_irq) {
        /*
         * In real hardware flow this should be wfi/RTOS wait and ISR will fire.
         * Here we keep a fallback path that can be used for bring-up.
         */
        platform_wait_for_irq_event();
        if (mipi_csi2_irq_pending(&csi)) {
            mipi_csi2_isr(&csi);
        }
    }

    mipi_csi2_request_stop(&csi, true);

    return 0;
}
