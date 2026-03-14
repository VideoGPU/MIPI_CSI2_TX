#include "mipi_csi2_axi.h"

/*
 * Replace these with your platform's MMIO primitives if needed.
 * The volatile pointer approach is enough for many bare-metal targets.
 */
static inline uint32_t mmio_read32(uintptr_t addr)
{
    return *((volatile uint32_t *)addr);
}

static inline void mmio_write32(uintptr_t addr, uint32_t value)
{
    *((volatile uint32_t *)addr) = value;
}

static uint32_t ctrl_mask_bit(uint32_t bit)
{
    return (1u << bit);
}

uint32_t mipi_csi2_read_reg(const mipi_csi2_axi_t *dev, uint32_t offset)
{
    return mmio_read32(dev->base_addr + offset);
}

void mipi_csi2_write_reg(const mipi_csi2_axi_t *dev, uint32_t offset, uint32_t value)
{
    mmio_write32(dev->base_addr + offset, value);
}

void mipi_csi2_get_default_config(mipi_csi2_config_t *cfg)
{
    cfg->n_mipi_lanes = 2u;
    cfg->pixels_per_line = 3240u;
    cfg->n_lines = 1944u;
    cfg->data_type = MIPI_CSI2_DT_RAW10;
    cfg->vc = 0u;
    cfg->frame_end_word = 0x1753u;

    /* Defaults mirror fmc_mipi_top.vhd register reset values. */
    cfg->tLP_SOT_Delay_clock = 0x002Au;
    cfg->tLPX_Delay_clock = 0x000Au;
    cfg->tLP_SOT_Delay_data = 0x00BBu;
    cfg->tLPX_Delay_data = 0x000Au;
    cfg->tLP_SOT_short_packet_delay = 0x030Fu;
    cfg->tHSprepare = 0x000Fu;
    cfg->tHSzero = 0x0050u;
    cfg->tHSexit = 0x000Au;

    cfg->irq_enable = true;
    cfg->legacy_trigger_enable = false;
    cfg->debug_overlay_enable = true;
}

void mipi_csi2_apply_config(const mipi_csi2_axi_t *dev, const mipi_csi2_config_t *cfg)
{
    uint32_t control = 0u;
    uint32_t type_vc = 0u;

    mipi_csi2_write_reg(dev, MIPI_CSI2_REG_N_MIPI_LANES, (uint32_t)(cfg->n_mipi_lanes & 0x03u));
    mipi_csi2_write_reg(dev, MIPI_CSI2_REG_PIXELS_PER_LINE, cfg->pixels_per_line);
    mipi_csi2_write_reg(dev, MIPI_CSI2_REG_N_LINES, cfg->n_lines);

    type_vc |= ((uint32_t)(cfg->data_type & 0x3Fu));
    type_vc |= ((uint32_t)(cfg->vc & 0x03u) << 8);
    mipi_csi2_write_reg(dev, MIPI_CSI2_REG_TYPE_VC, type_vc);

    mipi_csi2_write_reg(dev, MIPI_CSI2_REG_FRAME_END_WORD, cfg->frame_end_word);
    mipi_csi2_write_reg(dev, MIPI_CSI2_REG_TLP_SOT_DELAY_CLOCK, cfg->tLP_SOT_Delay_clock);
    mipi_csi2_write_reg(dev, MIPI_CSI2_REG_TLPX_DELAY_CLOCK, cfg->tLPX_Delay_clock);
    mipi_csi2_write_reg(dev, MIPI_CSI2_REG_TLP_SOT_DELAY_DATA, cfg->tLP_SOT_Delay_data);
    mipi_csi2_write_reg(dev, MIPI_CSI2_REG_TLPX_DELAY_DATA, cfg->tLPX_Delay_data);
    mipi_csi2_write_reg(dev, MIPI_CSI2_REG_TLP_SOT_SHORT_DELAY, cfg->tLP_SOT_short_packet_delay);
    mipi_csi2_write_reg(dev, MIPI_CSI2_REG_THS_PREPARE, cfg->tHSprepare);
    mipi_csi2_write_reg(dev, MIPI_CSI2_REG_THS_ZERO, cfg->tHSzero);
    mipi_csi2_write_reg(dev, MIPI_CSI2_REG_THS_EXIT, cfg->tHSexit);

    if (cfg->irq_enable) {
        control |= ctrl_mask_bit(MIPI_CSI2_CTRL_IRQ_EN_BIT);
    }
    if (cfg->legacy_trigger_enable) {
        control |= ctrl_mask_bit(MIPI_CSI2_CTRL_LEGACY_TRIG_EN_BIT);
    }
    if (cfg->debug_overlay_enable) {
        control |= ctrl_mask_bit(MIPI_CSI2_CTRL_DEBUG_OVR_EN_BIT);
    }

    /* Keep STOP cleared by default on setup. */
    mipi_csi2_write_reg(dev, MIPI_CSI2_REG_CONTROL, control);
}

void mipi_csi2_start(const mipi_csi2_axi_t *dev)
{
    uint32_t control = mipi_csi2_read_reg(dev, MIPI_CSI2_REG_CONTROL);

    /*
     * START is an edge command in bit0.
     * CONTROL writes also update bits [5:1], so preserve current settings.
     */
    control &= ~ctrl_mask_bit(MIPI_CSI2_CTRL_IRQ_CLEAR_BIT);
    control |= ctrl_mask_bit(MIPI_CSI2_CTRL_START_PULSE_BIT);
    mipi_csi2_write_reg(dev, MIPI_CSI2_REG_CONTROL, control);
}

void mipi_csi2_request_stop(const mipi_csi2_axi_t *dev, bool stop_enable)
{
    uint32_t control = mipi_csi2_read_reg(dev, MIPI_CSI2_REG_CONTROL);

    control &= ~ctrl_mask_bit(MIPI_CSI2_CTRL_STOP_BIT);
    if (stop_enable) {
        control |= ctrl_mask_bit(MIPI_CSI2_CTRL_STOP_BIT);
    }
    mipi_csi2_write_reg(dev, MIPI_CSI2_REG_CONTROL, control);
}

uint32_t mipi_csi2_get_status(const mipi_csi2_axi_t *dev)
{
    return mipi_csi2_read_reg(dev, MIPI_CSI2_REG_STATUS);
}

bool mipi_csi2_irq_pending(const mipi_csi2_axi_t *dev)
{
    return (mipi_csi2_get_status(dev) & ctrl_mask_bit(MIPI_CSI2_STS_IRQ_PEND_BIT)) != 0u;
}

void mipi_csi2_clear_irq(const mipi_csi2_axi_t *dev)
{
    uint32_t control = mipi_csi2_read_reg(dev, MIPI_CSI2_REG_CONTROL);

    control |= ctrl_mask_bit(MIPI_CSI2_CTRL_IRQ_CLEAR_BIT);
    mipi_csi2_write_reg(dev, MIPI_CSI2_REG_CONTROL, control);
}
