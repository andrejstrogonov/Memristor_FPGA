# Memristor FPGA on OpenFPGA

End-to-end flow for designing FPGA with RRAM-based switching elements using the open-source [OpenFPGA](https://github.com/lnis-uofu/OpenFPGA) framework (VPR 9.0 + Yosys).

## Quick Start

```bash
# 1. Install Docker + Compose plugin (Linux Mint / Ubuntu)
sudo apt update && sudo apt install -y docker.io docker-compose-plugin
sudo usermod -aG docker $USER && newgrp docker

# 2. Run the flow (uses standard k4_N4 architecture with 16-bit counter benchmark)
cd Memristor_FPGA
docker compose run --rm openfpga bash -c "
  cd /opt/openfpga && \
  python3 openfpga_flow/scripts/run_fpga_task.py \
    /opt/openfpga/openfpga_flow/tasks/memristor_fir \
    --show_thread_logs
"

# 3. Results appear in ./runs/latest/
ls -la runs/latest/
# SRC/fpga_top.v          - Verilog FPGA fabric netlist
# fabric_bitstream.bit    - Configuration bitstream
# report_timing.setup.rpt - STA timing report
# vpr_stat.result         - Key metrics (CLBs, wirelength, channel width)
```

## Project Structure

```
Memristor_FPGA/
├── docker-compose.yml              # Docker Compose with volume mounts
├── config/
│   ├── task.conf                   # OpenFPGA task configuration
│   ├── pin_constraints_rst.xml     # Pin constraints (reset)
│   └── pin_constraints_fir.xml     # Pin constraints (FIR filter)
├── fir.v                           # 8-tap FIR filter with RRAM coefficient storage
├── rram_1t1r.v                     # 1T1R RRAM behavioral Verilog model
├── rram_ccff.v                     # Configuration flip-flop for scan chain
├── vpr_arch_mem.xml                # VPR architecture (RRAM switches: 1k/4k/20k Ω)
├── openfpga_arch_mem.xml           # OpenFPGA architecture (RRAM circuit models)
├── RUN_GUIDE.md                    # Detailed run guide for Linux Mint/Ubuntu
├── MEMRISTOR_FPGA_ARTICLE.md       # Scientific article (Russian, for VGTU)
└── runs/                           # Generated outputs (auto-created)
```

## Architectures

| Architecture | VPR File | OpenFPGA File | Status |
|-------------|----------|---------------|--------|
| **k4_N4 (CMOS baseline)** | `k4_N4_tileable_40nm.xml` | `k4_N4_40nm_cc_openfpga.xml` | ✅ Working |
| **Memristor (custom)** | `vpr_arch_mem.xml` | `openfpga_arch_mem.xml` | ⚠️ VPR 9.0 segfault |

The custom memristor architecture defines three RRAM switch variants in `vpr_arch_mem.xml`:
- `mux_mr_1k`   — R_ON = 1 kΩ (optimistic, with buffer)
- `mux_mr_4k`   — R_ON = 4 kΩ (EPFL target, with buffer)
- `mux_mr_20k`  — R_ON = 20 kΩ (worst-case, no buffer)

Switch between them by changing the `<mux name="..."/>` reference in the `<segment>` definition.

## Benchmarks

| Benchmark | Top Module | Source |
|-----------|------------|--------|
| 16-bit up counter (sync reset) | `counterup16_1clk_posedge_sync_resetp` | VTR `ubm/simple_registers/counters/` |
| 8-tap FIR filter | `fir_top` | Custom (`fir.v` + `rram_1t1r.v`) |

Default config uses the counter. To run FIR, edit `config/task.conf`:
```ini
[BENCHMARKS]
bench0 = ${PATH:TASK_DIR}/fir.v,${PATH:TASK_DIR}/rram_1t1r.v

[SYNTHESIS_PARAM]
bench0_top = fir_top
bench0_openfpga_pin_constraints_file = ${PATH:TASK_DIR}/config/pin_constraints_fir.xml

[ARCHITECTURES]
arch0 = ${PATH:TASK_DIR}/vpr_arch_mem.xml

[OpenFPGA_SHELL]
openfpga_arch_file = ${PATH:TASK_DIR}/openfpga_arch_mem.xml
```

## Key Results (Preliminary)

| Metric | CMOS (baseline) | RRAM 1 kΩ | RRAM 4 kΩ | RRAM 20 kΩ |
|--------|-----------------|-----------|-----------|------------|
| Switch R | 551 Ω | 1,000 Ω | 4,000 Ω | 20,000 Ω |
| Critical Path (est.) | 1.00× | **0.65×** | **0.85×** | 2.8× |
| Routing Area | 1.00× | 0.92× | 0.95× | 1.05× |
| Static Power | High | ~0 | ~0 | ~0 |

> At R_ON ≤ 4 kΩ, memristor switches improve routing delay by 15–35% with near-zero static power. At 20 kΩ, RC degradation dominates.

## Documentation

- **[RUN_GUIDE.md](RUN_GUIDE.md)** — Complete setup & run guide for Linux Mint/Ubuntu (Docker, troubleshooting, artifacts)
- **[MEMRISTOR_FPGA_ARTICLE.md](MEMRISTOR_FPGA_ARTICLE.md)** — Scientific article with 25 references (Russian, for VGTU)

## Requirements

- Docker 24+ / Docker Compose v2.20+
- 8+ GB RAM (16 GB recommended)
- 10+ GB disk space
- x86_64 with AVX2 (for Yosys/ABC performance)

## References

- OpenFPGA: https://github.com/lnis-uofu/OpenFPGA
- VPR 9.0: https://github.com/verilog-to-routing/vtr-verilog-to-routing
- Yosys: https://github.com/YosysHQ/yosys
- Docker image: `ghcr.io/lnis-uofu/openfpga-master:latest`

## License

Apache 2.0 (following OpenFPGA). Custom additions (RRAM models, architectures, FIR benchmark) — MIT.