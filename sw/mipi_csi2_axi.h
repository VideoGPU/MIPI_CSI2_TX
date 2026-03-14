#ifndef MIPI_CSI2_AXI_H
#define MIPI_CSI2_AXI_H

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* AXI-Lite register offsets (must match hdl/fmc_mipi_top.vhd). */
enum {
    MIPI_CSI2_REG_CONTROL             = 0x00u,
    MIPI_CSI2_REG_STATUS              = 0x04u,
    MIPI_CSI2_REG_PIXELS_PER_LINE     = 0x10u,
    MIPI_CSI2_REG_N_LINES             = 0x14u,
    MIPI_CSI2_REG_TYPE_VC             = 0x18u,
    MIPI_CSI2_REG_FRAME_END_WORD      = 0x1Cu,
    MIPI_CSI2_REG_TLP_SOT_DELAY_CLOCK = 0x20u,
    MIPI_CSI2_REG_TLPX_DELAY_CLOCK    = 0x24u,
    MIPI_CSI2_REG_TLP_SOT_DELAY_DATA  = 0x28u,
    MIPI_CSI2_REG_TLPX_DELAY_DATA     = 0x2Cu,
    MIPI_CSI2_REG_TLP_SOT_SHORT_DELAY = 0x30u,
    MIPI_CSI2_REG_THS_PREPARE         = 0x34u,
    MIPI_CSI2_REG_THS_ZERO            = 0x38u,
    MIPI_CSI2_REG_THS_EXIT            = 0x3Cu,
    MIPI_CSI2_REG_N_MIPI_LANES        = 0x40u,
};

/* CONTROL register bit positions. */
enum {
    MIPI_CSI2_CTRL_START_PULSE_BIT    = 0u,
    MIPI_CSI2_CTRL_STOP_BIT           = 1u,
    MIPI_CSI2_CTRL_IRQ_EN_BIT         = 2u,
    MIPI_CSI2_CTRL_LEGACY_TRIG_EN_BIT = 3u,
    MIPI_CSI2_CTRL_IRQ_CLEAR_BIT      = 4u,
    MIPI_CSI2_CTRL_DEBUG_OVR_EN_BIT   = 5u,
};

/* STATUS register bit positions. */
enum {
    MIPI_CSI2_STS_HS_ACTIVE_BIT  = 0u,
    MIPI_CSI2_STS_HS_VALID_BIT   = 1u,
    MIPI_CSI2_STS_FRAME_DONE_BIT = 2u,
    MIPI_CSI2_STS_IRQ_PEND_BIT   = 3u,
};

/* MIPI data type convenience values (bits [5:0] in TYPE_VC register). */
enum {
    MIPI_CSI2_DT_FRAME_START = 0x00u,
    MIPI_CSI2_DT_FRAME_END   = 0x01u,
    MIPI_CSI2_DT_LINE_START  = 0x02u,
    MIPI_CSI2_DT_LINE_END    = 0x03u,
    MIPI_CSI2_DT_RAW10       = 0x2Bu,
};

/* Runtime lane configuration limits and register encoding. */
enum {
    MIPI_CSI2_MAX_N_MIPI_LANES      = 4u,
    MIPI_CSI2_REG_LANES_1           = 0x01u,
    MIPI_CSI2_REG_LANES_2           = 0x02u,
    MIPI_CSI2_REG_LANES_4           = 0x03u,
};

typedef struct {
    uintptr_t base_addr;
} mipi_csi2_axi_t;

typedef struct {
    uint8_t n_mipi_lanes;  /* Runtime lane count: 1, 2, or 4. */
    uint16_t pixels_per_line;
    uint16_t n_lines;
    uint8_t data_type;     /* 6-bit value. */
    uint8_t vc;            /* 2-bit value. */
    uint16_t frame_end_word;

    uint16_t tLP_SOT_Delay_clock;
    uint16_t tLPX_Delay_clock;
    uint16_t tLP_SOT_Delay_data;
    uint16_t tLPX_Delay_data;
    uint16_t tLP_SOT_short_packet_delay;
    uint16_t tHSprepare;
    uint16_t tHSzero;
    uint16_t tHSexit;

    bool irq_enable;
    bool legacy_trigger_enable;
    bool debug_overlay_enable;
} mipi_csi2_config_t;

uint32_t mipi_csi2_read_reg(const mipi_csi2_axi_t *dev, uint32_t offset);
void mipi_csi2_write_reg(const mipi_csi2_axi_t *dev, uint32_t offset, uint32_t value);

void mipi_csi2_get_default_config(mipi_csi2_config_t *cfg);
void mipi_csi2_apply_config(const mipi_csi2_axi_t *dev, const mipi_csi2_config_t *cfg);

void mipi_csi2_start(const mipi_csi2_axi_t *dev);
void mipi_csi2_request_stop(const mipi_csi2_axi_t *dev, bool stop_enable);

uint32_t mipi_csi2_get_status(const mipi_csi2_axi_t *dev);
bool mipi_csi2_irq_pending(const mipi_csi2_axi_t *dev);
void mipi_csi2_clear_irq(const mipi_csi2_axi_t *dev);

#ifdef __cplusplus
}
#endif

#endif
