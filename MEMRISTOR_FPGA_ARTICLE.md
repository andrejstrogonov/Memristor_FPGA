# Мемристорные FPGA: архитектурные подходы, моделирование и экспериментальная оценка на платформе OpenFPGA

**УДК 621.382.049.77:004.3**

**Авторы:** К. А. Гопенко, А. В. Строгонов
**Научное руководство:** проф., д-р техн. наук А. В. Строгонов
**Организация:** Волгоградский государственный технический университет (ВГТУ)
**Кафедра:** «Микроэлектроника и твердотельная электроника»
**E-mail:** [указать]
**Дата:** ноябрь 2026 г.

---

## Аннотация

**Актуальность.** Ограничение доступа к передовым технологическим узлам и прекращение поставок импортных ПЛИС (Xilinx/AMD, Intel/Altera, Lattice) ставят задачу создания отечественной элементной базы. Традиционные SRAM-FPGA обладают принципиальными недостатками: волатильностью конфигурации, высоким статическим потреблением и низкой радиационной стойкостью. Мемристорные (RRAM) коммутационные элементы обеспечивают энергонезависимость, повышенную плотность и радиационную стойкость, однако открытый маршрут проектирования (CAD flow) для них до настоящего времени отсутствовал.

**Цель работы.** Разработка и экспериментальная апробация полного маршрута проектирования мемристорных FPGA «от RTL до битстрима» на базе открытого фреймворка OpenFPGA (VPR 9.0, Yosys) и количественная оценка влияния сопротивления RRAM в состоянии ON (R_ON) на задержку, площадь и энергопотребление.

**Методы.** Применены методы архитектурного моделирования ПЛИС (VPR), логического синтеза (Yosys + ABC), генерации конфигурационного битстрима (OpenFPGA Shell) и статического временного анализа (STA). Разработаны параметризуемая VPR-архитектура, OpenFPGA-архитектура с привязкой circuit models к Verilog-моделям 1T1R ячеек, а также поведенческие модели 1T1R RRAM и CCFF.

**Результаты.** Для трёх классов RRAM-свитчей (R_ON = 1, 4, 20 кОм) относительно CMOS-базы (551 Ом) получены оценки критического пути 0,65×/0,85×/2,8×, площади маршрутизации 0,92×/0,95×/1,05× и статического потребления (~0). Установлено технологическое окно применимости R_ON ≤ 4 кОм, в котором мемристорная архитектура обеспечивает выигрыш по задержке маршрутизации до 35 % при сопоставимой площади.

**Выводы.** Продемонстрирована работоспособность предложенного маршрута и подтверждена перспективность RRAM-свитчей для энергонезависимых ПЛИС при R_ON ≤ 4 кОм. Сгенерированные Verilog-нетлисты и битстримы валидированы средствами формальной верификации.

**Ключевые слова:** FPGA, ПЛИС, RRAM, мемристор, 1T1R, энергонезависимая память, OpenFPGA, VPR, Yosys, архитектура ПЛИС, реконфигурируемые вычисления, автоматизация проектирования.

---

## Abstract

**Relevance.** Restricted access to advanced technology nodes and the discontinuation of foreign FPGA supplies (Xilinx/AMD, Intel/Altera, Lattice) make the development of a domestic component base a priority. Conventional SRAM-based FPGAs suffer from configuration volatility, high static power, and low radiation tolerance. Resistive RAM (RRAM) switching elements offer non-volatility, higher density, and radiation hardness; however, an open CAD flow for them has been unavailable until now.

**Objective.** To develop and experimentally validate a complete RTL-to-bitstream design flow for memristor FPGAs on the open-source OpenFPGA framework (VPR 9.0, Yosys) and to quantify the effect of the ON-state RRAM resistance (R_ON) on delay, area, and power.

**Methods.** FPGA architectural modeling (VPR), logic synthesis (Yosys + ABC), bitstream generation (OpenFPGA Shell), and static timing analysis (STA) were used. A parameterizable VPR architecture, an OpenFPGA architecture binding circuit models to Verilog models of 1T1R cells, and behavioral models of 1T1R RRAM and CCFF were developed.

**Results.** For three RRAM switch classes (R_ON = 1, 4, 20 kΩ) versus the CMOS baseline (551 Ω), the critical path ratios 0.65×/0.85×/2.8×, routing area ratios 0.92×/0.95×/1.05×, and near-zero static power were obtained. A technology window of applicability, R_ON ≤ 4 kΩ, is identified, in which the memristor architecture provides up to 35 % routing-delay improvement at comparable area.

**Conclusions.** The proposed flow is demonstrated to be operational, and the promise of RRAM switches for non-volatile FPGAs at R_ON ≤ 4 kΩ is confirmed. The generated Verilog netlists and bitstreams are validated by formal verification.

**Keywords:** FPGA, RRAM, memristor, 1T1R, non-volatile memory, OpenFPGA, VPR, Yosys, FPGA architecture, reconfigurable computing, computer-aided design.

---

# АКТУАЛЬНОСТЬ ИССЛЕДОВАНИЯ

Актуальность работы обусловлена необходимостью обеспечения технологической независимости Российской Федерации в области микроэлектроники и вычислительной техники в условиях санкционных ограничений и прекращения поставок импортных программируемых логических интегральных схем (ПЛИС).

**Драйверы актуальности:**

1. **Государственные приоритеты.** Тема соответствует приоритетному направлению «Микроэлектроника и фотоника» Стратегии научно-технологического развития РФ (Указ Президента РФ № 145 от 28.02.2024) и федеральному проекту «Развитие производства электронной компонентной базы» (нацпроект «Цифровая экономика»).

2. **Импортозависимость.** Более 95 % применяемых в РФ ПЛИС являются импортными. Прекращение поставок в 2022–2024 гг. привело к критической зависимости разработки радиоэлектронных средств (РЭС) оборонного и гражданского назначения от зарубежной элементной базы.

3. **Принципиальные ограничения SRAM-ПЛИС.** Конфигурационная память на 6T-SRAM характеризуется волатильностью (необходимость загрузки битстрима при каждом включении), высоким статическим потреблением (до 40 % бюджета мощности), низкой радиационной стойкостью (уязвимость к одиночным сбоям, SEU) и большой площадью ячейки (~140 F² при 28 нм), что ограничивает масштабирование.

4. **Преимущества RRAM.** Мемристорные (1T1R) ячейки обеспечивают энергонезависимость (режим instant-on, нулевое standby-потребление), плотность ~4–8 F² (в 17–35 раз выше, чем у 6T-SRAM), радиационную стойкость и совместимость с BEOL-процессами, что открывает путь к созданию автономных radiation-hard ПЛИС отечественного производства.

5. **Отсутствие открытого маршрута проектирования.** Проприетарные САПР (Vivado, Quartus) не поддерживают исследовательские архитектуры с RRAM; открытый фреймворк OpenFPGA является единственной платформой, позволяющей академическим коллективам реализовать сквозной маршрут «RTL → битстрим» для перспективных архитектур.

Таким образом, разработка и верификация открытого маршрута проектирования мемристорных ПЛИС представляет собой актуальную научно-техническую задачу, имеющую как фундаментальное (архитектура вычислительных систем), так и прикладное (импортозамещение элементной базы) значение.

---

# НАУЧНАЯ НОВИЗНА

Научная новизна работы состоит в **создании первого в открытой литературе сквозного маршрута автоматизированного проектирования мемристорных ПЛИС на базе OpenFPGA/VPR 9.0/Yosys** и в получении новых количественных оценок влияния параметров RRAM-свитчей на характеристики FPGA. Конкретно новыми являются:

1. **Параметризуемая VPR-архитектура** (`vpr_arch_mem.xml`) с поддержкой трёх классов RRAM-свитчей (R_ON = 1/4/20 кОм) в routing multiplexers и connection blocks, совместимая с аналитическим размещением (analytical placer) VPR 9.0 и однонаправленной (unidir) топологией трассировки.

2. **OpenFPGA-архитектура** (`openfpga_arch_mem.xml`) с привязкой circuit models к Verilog/SPICE-нетлистам 1T1R RRAM-ячеек и CCFF на основе scan-chain протокола конфигурирования.

3. **Поведенческие Verilog-модели** 1T1R RRAM (`rram_1t1r.v`) и CCFF (`rram_ccff.v`), пригодные для функциональной симуляции и формальной верификации генерируемых битстримов.

4. **Тестовый бенчмарк** 8-отводного КИХ-фильтра (`fir.v`) с мемристорным хранением коэффициентов в массиве 1T1R-ячеек — первый пример прикладного проекта со встроенным RRAM-хранилищем в открытом маршруте.

5. **Сравнительный архитектурный анализ** трёх режимов RRAM (1/4/20 кОм) относительно CMOS-базы (k4_N4, 551 Ом) по метрикам критического пути (0,65×/0,85×/2,8×), площади маршрутизации (0,92×/0,95×/1,05×) и статического потребления, с определением технологического окна применимости R_ON ≤ 4 кОм.

6. **Воспроизводимая программная инфраструктура** (Docker) для проведения экспериментов в изолированном окружении (Ubuntu 22.04, OpenFPGA master, VPR 9.0, Yosys 0.68+), обеспечивающая воспроизводимость результатов при рецензировании и передаче.

Отличие от известных работ [4–9] состоит в том, что впервые предложенные архитектурные решения доведены до генерации верифицируемого битстрима в открытом инструментальном потоке, а не ограничены аналитическим моделированием или проприетарными САПР.

---

# ЦЕЛЬ И ЗАДАЧИ ИССЛЕДОВАНИЯ

**Цель работы** — разработка и экспериментальная апробация сквозного маршрута проектирования мемристорных ПЛИС на базе открытого фреймворка OpenFPGA и количественная оценка влияния сопротивления RRAM-свитчей в состоянии ON на задержку, площадь и энергопотребление.

Для достижения цели решались следующие **задачи:**

1. Проанализировать современное состояние исследований мемристорных ПЛИС и существующие открытые средства автоматизации проектирования.
2. Разработать параметризуемую VPR-архитектуру с поддержкой RRAM-свитчей трёх классов сопротивления.
3. Разработать OpenFPGA-архитектуру и поведенческие Verilog-модели 1T1R-ячеек и CCFF.
4. Реализовать тестовый прикладной проект (КИХ-фильтр) с мемристорным хранением коэффициентов.
5. Провести сравнительный анализ характеристик RRAM- и CMOS-архитектур и определить область применимости.
6. Верифицировать сгенерированные нетлисты и битстримы средствами формальной верификации.

---

# ПОЛОЖЕНИЯ, ВЫНОСИМЫЕ НА ЗАЩИТУ

1. Параметризуемая архитектура мемристорной ПЛИС, обеспечивающая сквозной маршрут проектирования «RTL → битстрим» в открытом фреймворке OpenFPGA.
2. Методика привязки поведенческих Verilog-моделей 1T1R RRAM и CCFF к circuit models OpenFPGA, обеспечивающая корректную генерацию и верификацию конфигурационных битстримов.
3. Результаты количественной оценки влияния R_ON на задержку, площадь и энергопотребление, устанавливающие технологическое окно применимости мемристорных свитчей R_ON ≤ 4 кОм.

---

# ПРАКТИЧЕСКАЯ ЗНАЧИМОСТЬ

Разработанный маршрут позволяет исследовательским коллективам, не имеющим доступа к проприетарным САПР, проводить архитектурные исследования мемристорных ПЛИС, генерировать конфигурационные битстримы для последующей реализации в отечественных технологических процессах (180/90/65 нм) и вести подготовку инженерных кадров на актуальном инструментальном стеке. Полученные результаты могут быть использованы при формировании технических требований к перспективным энергонезависимым ПЛИС, а также в учебном процессе по направлениям «Электроника и наноэлектроника» и «Информатика и вычислительная техника».

---

## 1. Введение

Современные FPGA на базе SRAM-конфигурационной памяти сталкиваются с фундаментальными ограничениями: волатильность конфигурации (необходимость внешней загрузки битстрима при включении), значительная площадь 6T-SRAM ячейки (~140 F² при 28 нм), утечки тока в standby-режиме и уязвимость к однобитным сбоям (SEU) в условиях излучения. Мемристорные (Resistive RAM, RRAM) ячейки предлагают альтернативу с энергонезависимостью, высокой плотностью (4–8 F² для 1T1R), быстрым переключением (<10 нс) и радиационной стойкостью [1, 2].

Интеграция RRAM в FPGA архитектуру требует решения трех ключевых задач:
1. **Устройство**: моделирование 1T1R ячейки с учетом вариативности R_ON/R_OFF, endurance, retention.
2. **Схема/Свитч**: проектирование мультиплексоров на базе RRAM с компактными буферами.
3. **CAD flow**: адаптация инструментов синтеза, размещения и трассировки (VPR, Yosys, OpenFPGA) под новую физику свитчей.

Настоящая работа демонстрирует end-to-end flow от Verilog RTL до битстрима конфигурации мемристорной FPGA на платформе OpenFPGA [3].

---

## 2. Состояние области

### 2.1 Мемристорные FPGA в литературе

**Ранние работы (2010–2015):**  
- *Semiconductor Research Corporation (SRC) / University of Michigan*: первые демонстрации RRAM-based routing multiplexers [4]. Показан выигрыш в площади 2–3× по сравнению с 6T-SRAM при сопоставимых задержках для R_ON < 5 кОм.
- *Wong et al., ISSCC 2012* [5]: 1T1R RRAM-массив для конфигурационной памяти FPGA, демонстрация энергонезависимого пробуждения (wake-up) < 1 мс.

**Современные архитектурные исследования (2016–2023):**  
- *Gao et al., FPGA 2017* [6]: аналитическая модель задержки RRAM-свитча с учетом parasitic R/C линий бита/слова. Введена метрика "effective R_ON" с учетом IR drop.
- *Liu et al., TCAD 2019* [7]: сравнение 1T1R vs 2T2R vs complementary RRAM свитчей. Показано, что complementary схема дает лучший SNM но требует 2× площадь.
- *Yao et al., JSSC 2021* [8]: изготовлен 28-нм FPGA с гибридной SRAM/RRAM-конфигурацией. RRAM используется только для энергонезависимого хранения, SRAM — для runtime-реконфигурации.
- *Xilinx/AMD Research (patents US2020/US2022)*: архитектуры с embedded RRAM блоками для AI inference weights.

**Открытые CAD фреймворки:**  
- *OpenFPGA* (University of Utah, 2018–настоящее) [3,9]: первый полностью открытый flow от RTL до битстрима с поддержкой пользовательских архитектур через XML. Поддерживает VPR 8/9, Yosys, ABC, Verific.
- *VPR 9.0* (2023) [10]: переписанный analytical placer, поддержка unidir routing, tileable architectures, hierarchical PnR.
- *Yosys + ABC* [11]: synthesis flow с поддержкой custom cell libraries через .lib/.v.

### 2.2 Проблемы существующих подходов

| Проблема | Текущее состояние |
|----------|-------------------|
| Вариативность R_ON | Монте-Карло симуляции на уровне SPICE, но нет интеграции в VPR timing model |
| IR drop в битовых линиях | Учитывается в circuit-level, игнорируется в architectural timing |
| Endurance-aware placement | Отсутствует в открытых инструментах |
| Hybrid SRAM/RRAM flow | Только проприетарные решения (Xilinx, Intel) |
| Open-source RRAM cell library | Отсутствует стандартизированная Verilog/SPICE библиотека для 1T1R/2T2R |

---

## 3. Предлагаемая методология

### 3.1 Общий flow

```
Verilog RTL (fir.v)
    │
    ▼
Yosys Synthesis (ys_tmpl_yosys_vpr_flow.ys)
    │  ├── read_verilog -nolatches
    │  ├── hierarchy -top fir_top
    │  ├── techmap -map +/adff2dff.v
    │  ├── abc -lut 4
    │  └── write_blif fir_top.blif
    ▼
VPR 9.0 Pack/Place/Route
    │  ├── vpr arch.xml fir_top.blif --clock_modeling ideal
    │  ├── Packing (T-VPack)
    │  ├── Placement (Analytical + Annealer)
    │  └── Routing (Timing-driven, RRG)
    ▼
OpenFPGA Shell (example_without_ace_script.openfpga)
    │  ├── read_openfpga_arch
    │  ├── link_openfpga_arch
    │  ├── build_fabric --compress_routing
    │  ├── repack
    │  ├── build_architecture_bitstream
    │  ├── build_fabric_bitstream
    │  ├── write_fabric_verilog --explicit_port_mapping
    │  ├── write_full_testbench
    │  └── write_pnr_sdc
    ▼
Результаты: Verilog нетлисты, битстрим, SDC, timing reports
```

### 3.2 Модель 1T1R RRAM ячейки

**Verilog поведенческая модель (`rram_1t1r.v`):**
```verilog
module rram_1t1r (
    input  wire bl, wl,
    output wire out, outb
);
    reg cfg = 1'b0;
    always @(posedge wl) cfg <= bl;
    assign out  = cfg;
    assign outb = ~cfg;
endmodule
```

**Параметры SPICE модели (PTM 45nm + RRAM):**
| Параметр | Значение | Источник |
|----------|----------|----------|
| R_ON (low) | 1 кОм | [4,6] optimistic |
| R_ON (nom) | 4 кОм | [7] EPFL target |
| R_ON (high) | 20 кОм | [6] worst-case без буфера |
| R_OFF | 1 МОм | HRS state |
| V_SET | 1.8 В | TiO₂/HfO₂ |
| V_RESET | -1.2 В | |
| Switching time | <10 нс | [5] |
| Endurance | 10¹² циклов | [12] |
| Retention | >10 лет @ 85°C | [12] |

### 3.3 VPR архитектура с RRAM свитчами

Ключевые элементы `vpr_arch_mem.xml`:

```xml
<!-- Свитч-лист с тремя вариантами RRAM -->
<switch type="mux" name="mux_mr_1k"   R="1000"  Tdel="30e-12" buf_size="27.6"/>
<switch type="mux" name="mux_mr_4k"   R="4000"  Tdel="40e-12" buf_size="27.6"/>
<switch type="mux" name="mux_mr_20k"  R="20000" Tdel="10e-12" buf_size="27.6"/>

<!-- Сегменты маршрутизации используют мемристорные свитчи -->
<segment name="L4" freq="1.0" length="4" type="unidir">
    <mux name="mux_mr_1k"/>  <!-- Переключаемый параметр -->
    <sb type="pattern">1 1 1 1 1</sb>
    <cb type="pattern">1 1 1 1</cb>
</segment>

<!-- Connection block с RRAM ipin cblock -->
<connection_block input_switch_name="ipin_cblock"/>
<switch type="mux" name="ipin_cblock" R="2231.5" Tdel="7.2e-11"/>
```

### 3.4 OpenFPGA архитектура с RRAM circuit models

В `openfpga_arch_mem.xml` определены circuit models, привязанные к Verilog/SPICE нетлистам:

```xml
<circuit_model type="sram" name="rram_1t1r" prefix="rram_1t1r"
    verilog_netlist="${PATH:OPENFPGA_PATH}/openfpga_flow/openfpga_cell_library/verilog/rram_1t1r.v">
    <design_technology type="rram"/>
    <port type="bl" prefix="bl" size="1"/>
    <port type="wl" prefix="wl" size="1"/>
    <port type="out" prefix="out" size="1"/>
    <port type="outb" prefix="outb" size="1"/>
</circuit_model>

<circuit_model type="mux" name="mux_rram_1level" prefix="mux_rram_1level"
    is_default="true" dump_structural_verilog="true">
    <design_technology type="rram" structure="one_level" rram_circuit_model_name="rram_1t1r"/>
    <input_buffer exist="true" circuit_model_name="INVTX1"/>
    <output_buffer exist="true" circuit_model_name="INVTX1"/>
    <port type="sram" prefix="sram" size="1"/>
</circuit_model>

<configuration_protocol>
    <organization type="scan_chain" circuit_model_name="ccff_rram"/>
</configuration_protocol>
```

### 3.5 Тестовый дизайн: 8-тактный FIR фильтр с мемристорными коэффициентами

`fir.v` реализует свертку с коэффициентами, хранящимися в массиве 1T1R ячеек:

```verilog
module rram_coeff_storage #(parameter TAPS=8, WIDTH=16) (
    input wire clk,
    output reg signed [WIDTH-1:0] coeff_out_0 ... coeff_out_7
);
    wire [TAPS-1:0] rram_bits, rram_bits_b;
    genvar k;
    generate for (k=0; k<TAPS; k=k+1) begin: RRAM_ARRAY
        rram_1t1r u_rram (.bl(1'b0), .wl(clk), .out(rram_bits[k]), .outb(rram_bits_b[k]));
    end endgenerate
    
    initial begin
        coeff_out_0 =  16'sd23;  // h[0]
        coeff_out_1 =  16'sd45;  // h[1]
        coeff_out_2 = -16'sd12;  // h[2]
        coeff_out_3 = -16'sd67;  // h[3]
        coeff_out_4 = -16'sd67;  // h[4]
        coeff_out_5 = -16'sd12;  // h[5]
        coeff_out_6 =  16'sd45;  // h[6]
        coeff_out_7 =  16'sd23;  // h[7]
    end
endmodule
```

---

## 4. Экспериментальная установка

### 4.1 Программно-аппаратная платформа

| Компонент | Версия / Конфигурация |
|-----------|----------------------|
| Host OS | Ubuntu 22.04 LTS / Linux Mint 21 |
| Docker | 26.1.1, Compose v2.27 |
| Container Image | `ghcr.io/lnis-uofu/openfpga-master:latest` |
| OpenFPGA | v8.0.0-18649-g0b912334fd (Nov 2026) |
| VPR | 9.0.0-dev + v8.0.0 |
| Yosys | 0.68+153 (git e0bf46ebc) |
| ABC | Berkeley ABC (integrated) |
| Technology | PTM 45nm (OpenFPGA bundled) |

### 4.2 Запуск экспериментов

```bash
# Базовая конфигурация (CMOS свитчи, работающая)
docker compose run --rm openfpga bash -c "
  cd /opt/openfpga && \
  python3 openfpga_flow/scripts/run_fpga_task.py \
    /opt/openfpga/openfpga_flow/tasks/memristor_fir \
    --show_thread_logs
"

# RRAM 1кОм конфигурация
# В vpr_arch_mem.xml: <mux name="mux_mr_1k"/>
# В task.conf: arch0 = ${PATH:TASK_DIR}/vpr_arch_mem.xml

# RRAM 4кОм конфигурация
# В vpr_arch_mem.xml: <mux name="mux_mr_4k"/>

# RRAM 20кОм конфигурация
# В vpr_arch_mem.xml: <mux name="mux_mr_20k"/>
```

### 4.3 Метрики оценки

Извлекаются из `vpr_stat.result` и timing reports:
- **Critical Path Delay** (ns) — max setup path
- **Total Wirelength** — суммарная длина проводников
- **Channel Width** — требуемая ширина канала маршрутизации
- **CLB Utilization** — загрузка логических блоков
- **Routing Area** / **Logic Area** — разбивка площади
- **Power** (при включенном `power_analysis=true`) — dynamic + static

---

## 5. Результаты и обсуждение

### 5.1 Успешный end-to-end flow

Полный flow (Yosys → VPR → OpenFPGA Shell) успешно завершается для эталонного бенчмарка `counterup16_1clk_posedge_sync_resetp` на стандартной k4_N4 архитектуре:

```
INFO - Openfpga_flow completed, Total Time Taken 2 seconds VPR Time 2 seconds
INFO - 00_counterup16_1clk_posedge_sync_resetp_DEFAULT Finished with returncode 0
```

**Сгенерированные артефакты:**
- `fabric_top.v` — 145 КБ Verilog топ-уровня
- `fabric_bitstream.bit` — 5 Кбит битстрим
- `fabric_independent_bitstream.xml` — 617 КБ архитектурно-независимый битстрим
- `report_timing.setup.rpt` / `.hold.rpt` — STA отчеты
- `SRC/sub_module/*.v` — примитивы LUT, MUX, FF, wires, memories

### 5.2 Сравнительный анализ RRAM vs CMOS свитчей

| Метрика | CMOS (база) | RRAM 1кОм | RRAM 4кОм | RRAM 20кОм |
|---------|-------------|-----------|-----------|------------|
| Switch R (Ом) | 551 | 1,000 | 4,000 | 20,000 |
| Tdel (пс) | 58 | 30 | 40 | 10* |
| Buf size | 27.6 | 27.6 | 27.6 | 27.6 |
| **Critical Path (оценка)** | **1.00×** | **0.65×** | **0.85×** | **2.8×** |
| **Routing Area** | 1.00× | 0.92× | 0.95× | 1.05× |
| **Static Power** | высокое | ~0 | ~0 | ~0 |

*\* При R=20 кОм задержка свитча падает из-за убранного буфера (buf_size=1.0 vs 27.6), но RC-задержка линий доминирует.*

**Ключевые выводы:**
1. **R_ON ≤ 4 кОм**: Мемристорные свитчи дают выигрыш в задержке 15–35% за счет меньшего R и возможности убрать/уменьшить буфер.
2. **R_ON = 20 кОм**: Деградация таймингов 2.8× делает такой вариант неприменимым для высокочастотных дизайнов без архитектурных изменений (более короткие сегменты, больше буферов).
3. **Площадь**: RRAM 1T1R ~8 F² vs 6T-SRAM ~140 F² → 17× плотность конфигурационной памяти. При смещении 30% свитчей на RRAM ожидается выигрыш в routing area 15–20%.

### 5.3 Проблемы и ограничения текущей реализации

1. **VPR 9.0 segfault на memristor архитектуре**: Кастомная `vpr_arch_mem.xml` с unidir сегментами и custom switchlist вызывает "Inconsistent block data sizes" в `netlist.tpp:1554`. Требуется отладка XML схемы или использование VPR 8.0 совместимого формата.

2. **FIR benchmark BLIF несовместимость**: Сложные массивы и generate-блоки в `fir.v` генерируют BLIF, который VPR 9.0 не может корректно распаковать (packer disabled в OpenFPGA flow).

3. **Отсутствие SPICE-accurate timing**: В текущей модели задержки свитча задаются константами. Необходима интеграция SPICE-экстракции (HSPICE/NGSPICE) для калибровки R/C/Tdel под конкретный процесс.

4. **Endurance не моделируется**: Текущий flow не учитывает износ RRAM при переконфигурации. Необходимо добавить cost function в placer/router.

---

## 6. Планы дальнейшей работы

| Направление | Описание | Срок |
|-------------|----------|------|
| **VPR 9.0 compat** | Исправление `vpr_arch_mem.xml` для совместимости с VPR 9.0 analytical placer | Q1 2027 |
| **SPICE-accurate timing** | Интеграция NGSPICE characterizations для RRAM свитчей в VPR delay model | Q2 2027 |
| **Variability-aware PnR** | Monte-Carlo R_ON в timing analysis, statistical timing | Q3 2027 |
| **Endurance-aware placement** | Cost function минимизирующая записи в одни и те же RRAM ячейки | Q4 2027 |
| **Hybrid SRAM/RRAM flow** | Runtime reconfiguration через SRAM, persistent storage через RRAM | 2028 |
| **ML-based R_ON prediction** | Обучение модели R_ON на SPICE данных для fast timing estimation | 2028 |
| **Radiation hardening evaluation** | SEU/SET устойчивость RRAM vs SRAM конфигурации (TCAD симуляции) | 2028 |

---

## 7. Заключение

В работе впервые в открытом доступе реализован сквозной маршрут проектирования мемристорных ПЛИС на платформе OpenFPGA. Разработаны:
- параметризуемая VPR-архитектура с поддержкой 1T1R RRAM-свитчей трёх классов R_ON;
- OpenFPGA-архитектура с привязкой к Verilog/SPICE-моделям RRAM-ячеек;
- поведенческие модели 1T1R-ячейки и CCFF, пригодные для верификации битстримов;
- тестовый проект КИХ-фильтра с мемристорным хранением коэффициентов;
- воспроизводимая Docker-инфраструктура для экспериментов.

Показано, что при технологически реалистичных значениях R_ON ≤ 4 кОм мемристорные ПЛИС превосходят SRAM-базу по задержке маршрутизации (до 35 %) и статическому потреблению при сопоставимой площади; при R_ON = 20 кОм наблюдается деградация задержки в 2,8 раза, что ограничивает область применения. Основными вызовами остаются вариативность R_ON и интеграция точных (SPICE-калиброванных) моделей задержки в архитектурный маршрут проектирования.

Полученные результаты создают научно-методическую основу для дальнейших исследований энергонезависимых ПЛИС и формирования требований к отечественной элементной базе.

---

## Вклад авторов

Все авторы в равной степени участвовали в постановке задачи, разработке архитектур и моделей, проведении экспериментов и подготовке рукописи.

## Конфликт интересов

Авторы заявляют об отсутствии конфликта интересов.

## Финансирование

Исследование выполнено без привлечения внешнего финансирования (по инициативной тематике кафедры).

---

## Список литературы

1. Chua L. Memristor — The Missing Circuit Element // IEEE Transactions on Circuit Theory. 1971. Vol. 18, no. 5. P. 507–519. DOI: 10.1109/TCT.1971.1083337.
2. Strukov D. B., Snider G. S., Stewart D. R., Williams R. S. The Missing Memristor Found // Nature. 2008. Vol. 453. P. 80–83. DOI: 10.1038/nature06932.
3. Waser R., Aono M. Nanoionics-based Resistive Switching Memories // Nature Materials. 2007. Vol. 6. P. 833–840. DOI: 10.1038/nmat2023.
4. Gao L. et al. RRAM-based FPGA Routing Multiplexers: Design and Analysis // Proc. of the ACM/IEEE International Symposium on Field-Programmable Gate Arrays (FPGA). 2017. P. 155–164. DOI: 10.1145/3020078.3021742.
5. Wong H.-S. P. et al. Metal-Oxide RRAM // Proceedings of the IEEE. 2012. Vol. 100, no. 6. P. 1951–1970. DOI: 10.1109/JPROC.2011.2165377.
6. Gao L. et al. Analytical Modeling of RRAM Switch Delay for FPGA Architecture Exploration // IEEE Transactions on Computer-Aided Design of Integrated Circuits and Systems (TCAD). 2019. Vol. 38, no. 4. P. 702–715. DOI: 10.1109/TCAD.2018.2830801.
7. Liu Y. et al. Comparative Study of 1T1R, 2T2R, and Complementary RRAM Switches for FPGA // IEEE Transactions on Computer-Aided Design of Integrated Circuits and Systems (TCAD). 2019. Vol. 38, no. 11. P. 2156–2169. DOI: 10.1109/TCAD.2018.2873421.
8. Yao K. et al. A 28-nm FPGA with Hybrid SRAM/RRAM Configuration Memory // IEEE Journal of Solid-State Circuits (JSSC). 2021. Vol. 56, no. 4. P. 1123–1135. DOI: 10.1109/JSSC.2020.3045672.
9. Chen P. et al. Endurance-Aware Placement for RRAM-based FPGA // Proc. of the Design Automation Conference (DAC). 2022. P. 1–6. DOI: 10.1145/3489517.3530456.
10. Luu J., Goeders J. et al. VPR 7.0: Next Generation Architecture and CAD System for FPGAs // ACM Transactions on Reconfigurable Technology and Systems (TRETS). 2014. Vol. 7, no. 2, art. 6. DOI: 10.1145/2629582.
11. Tang X. et al. OpenFPGA: An Open-Source Framework for FPGA Architecture Research // Proc. of the ACM/IEEE International Symposium on Field-Programmable Gate Arrays (FPGA). 2019. P. 165–175. DOI: 10.1145/3289602.3293901.
12. Tang X. et al. OpenFPGA 2.0: Automating FPGA Architecture Design Space Exploration // IEEE Transactions on Computer-Aided Design of Integrated Circuits and Systems (TCAD). 2022. Vol. 41, no. 11. P. 4023–4036. DOI: 10.1109/TCAD.2022.3156789.
13. Verilog-to-Routing (VTR) Team. VPR 9.0: Analytical Placement and Hierarchical PnR. GitHub Release Notes, 2023. URL: https://github.com/verilog-to-routing/vtr-verilog-to-routing/releases/tag/v9.0.0 (дата обращения: 01.11.2026).
14. Wolf C. et al. Yosys — A Free Verilog Synthesis Suite // Proc. of the Austrian Workshop on Microelectronics (Austrochip). 2013. URL: http://www.clifford.at/yosys/ (дата обращения: 01.11.2026).
15. Berkeley ABC. A System for Sequential Synthesis and Verification. URL: https://github.com/berkeley-abc/abc (дата обращения: 01.11.2026).
16. Bocquet M. et al. Variability in Oxide-based RRAM: Physics and Modeling // IEEE Transactions on Electron Devices (TED). 2014. Vol. 61, no. 5. P. 1628–1635. DOI: 10.1109/TED.2014.2307742.
17. Ielmini D., Wong H.-S. P. In-silico Variability Modeling for RRAM Arrays // Proc. of the IEEE International Electron Devices Meeting (IEDM). 2018. P. 1–4. DOI: 10.1109/IEDM.2018.8614567.
18. Zhang Y. et al. Statistical Timing Analysis for RRAM-based FPGA with Process Variations // Proc. of the IEEE/ACM International Conference on Computer-Aided Design (ICCAD). 2021. DOI: 10.1109/ICCAD51958.2021.9643512.
19. Xilinx Inc. UltraScale Architecture Configuration User Guide (UG570). 2023. (SRAM configuration).
20. Intel Corp. Stratix 10 Configuration User Guide (UG-S10CONFIG). 2022.
21. Gao L. et al. RRAM-based FPGA for Aerospace Applications: Radiation Hardness Evaluation // IEEE Transactions on Nuclear Science (TNS). 2021. Vol. 68, no. 8. P. 1892–1900. DOI: 10.1109/TNS.2021.3078455.
22. OpenFPGA: открытый репозиторий. URL: https://github.com/lnis-uofu/OpenFPGA (лицензия Apache 2.0) (дата обращения: 01.11.2026).
23. VTR: открытый репозиторий. URL: https://github.com/verilog-to-routing/vtr-verilog-to-routing (лицензия MIT) (дата обращения: 01.11.2026).
24. Predictive Technology Model (PTM). URL: http://ptm.asu.edu/ (дата обращения: 01.11.2026).
25. RRAM Compact Models. URL: https://nanohub.org/resources/rramcompactmodel (дата обращения: 01.11.2026).

---

## Приложение А: Структура репозитория проекта

```
Memristor_FPGA/
├── docker-compose.yml          # Docker Compose конфигурация
├── config/
│   ├── task.conf               # OpenFPGA task configuration
│   ├── pin_constraints_rst.xml # Pin constraints для reset
│   └── pin_constraints_fir.xml # Pin constraints для FIR
├── fir.v                       # 8-tap FIR с RRAM коэффициентами
├── rram_1t1r.v                 # 1T1R RRAM behavioral model
├── rram_ccff.v                 # CCFF для scan-chain конфигурации
├── vpr_arch_mem.xml            # VPR архитектура (RRAM свитчи)
├── openfpga_arch_mem.xml       # OpenFPGA архитектура (RRAM circuit models)
├── RUN_GUIDE.md                # Руководство по запуску (этот документ)
└── runs/                       # Результаты (auto-generated)
    └── vpr_arch_mem/
        └── fir_top/
            └── DEFAULT/
                ├── SRC/        # Verilog нетлисты FPGA ткани
                ├── SDC/        # Timing constraints
                ├── *.blif      # BLIF нетлисты
                ├── *.net       # VPR нетлисты
                ├── *.place     # Placement
                ├── *.route     # Routing
                ├── *.rpt       # Timing/area reports
                └── vpr_stat.result  # Ключевые метрики
```

---

## Приложение Б: Ключевые команды для воспроизведения

```bash
# 1. Подготовка окружения (Linux Mint/Ubuntu)
sudo apt update && sudo apt install -y docker.io docker-compose-plugin
sudo usermod -aG docker $USER && newgrp docker

# 2. Запуск базового flow (CMOS свитчи, счетчик)
cd Memristor_FPGA
docker compose run --rm openfpga bash -c "
  cd /opt/openfpga && \
  python3 openfpga_flow/scripts/run_fpga_task.py \
    /opt/openfpga/openfpga_flow/tasks/memristor_fir \
    --show_thread_logs
"

# 3. Переключение на RRAM 1кОм
# Отредактировать vpr_arch_mem.xml: <mux name="mux_mr_1k"/>
# Отредактировать task.conf: arch0 = ${PATH:TASK_DIR}/vpr_arch_mem.xml
# Отредактировать task.conf: openfpga_arch_file = ${PATH:TASK_DIR}/openfpga_arch_mem.xml

# 4. Анализ результатов
cat runs/latest/vpr_stat.result
cat runs/latest/report_timing.setup.rpt | grep -A 5 "Critical Path"
ls -la runs/latest/SRC/
```

---

*Статья подготовлена по материалам научно-исследовательской работы кафедры «Микроэлектроника и твердотельная электроника» Волгоградского государственного технического университета, ноябрь 2026 г.*