# Руководство по запуску проекта OpenFPGA через Docker Compose на Linux Mint / Ubuntu

## Требования

### Системные требования
- **ОС**: Linux Mint 21+ / Ubuntu 22.04+ (или любой дистрибутив с поддержкой Docker)
- **Docker**: версии 24.0+
- **Docker Compose**: версии 2.20+ (plugin или standalone)
- **RAM**: минимум 8 ГБ (рекомендуется 16+ ГБ)
- **Диск**: минимум 10 ГБ свободного места
- **CPU**: x86_64 (поддержка AVX2 желательна для Yosys/ABC)

### Установка Docker и Docker Compose

```bash
# Обновление пакетов
sudo apt update && sudo apt upgrade -y

# Установка зависимостей
sudo apt install -y ca-certificates curl gnupg lsb-release

# Добавление официального GPG ключа Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Добавление репозитория Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Установка Docker Engine + Compose plugin
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Добавление пользователя в группу docker (перелогиниться после!)
sudo usermod -aG docker $USER
newgrp docker
```

### Проверка установки
```bash
docker --version
# Docker version 26.x.x, build xxx

docker compose version
# Docker Compose version v2.27.x
```

---

## Структура проекта

```
F:\Kirill\Memristor_FPGA\                    # Корневая директория проекта
├── docker-compose.yml                    # Конфигурация Docker Compose
├── config/
│   ├── task.conf                         # Конфигурация OpenFPGA flow
│   ├── pin_constraints_rst.xml           # Pin constraints для reset
│   └── pin_constraints_fir.xml           # Pin constraints для FIR (опционально)
├── fir.v                                 # RTL: FIR фильтр с мемристорными коэффициентами
├── rram_1t1r.v                           # Verilog модель 1T1R RRAM ячейки
├── rram_ccff.v                           # Verilog модель CCFF (configuration flip-flop)
├── vpr_arch_mem.xml                      # VPR архитектура (мемристорная)
├── openfpga_arch_mem.xml                 # OpenFPGA архитектура (мемристорная)
└── runs/                                 # Результаты генерации (создаются автоматически)
    └── vpr_arch_mem/
        └── fir_top/
            └── DEFAULT/
                ├── SRC/                  # Verilog нетлисты FPGA ткани
                ├── SDC/                  # Timing constraints
                ├── fabric_bitstream.bit  # Битстрим конфигурации
                ├── *.blif                # BLIF нетлисты
                ├── *.net                 # VPR нетлисты
                ├── *.place               # Placement файлы
                ├── *.route               # Routing файлы
                ├── *.rpt                 # Timing/area отчеты
                └── vpr_stdout.log        # Лог VPR
```

---

## Запуск проекта

### 1. Клонирование / копирование проекта
```bash
# Если проект в git репозитории
git clone <repository_url>
cd Memristor_FPGA

# Или просто скопируйте папку Memristor_FPGA в домашнюю директорию
cp -r /путь/к/Memristor_FPGA ~/Memristor_FPGA
cd ~/Memristor_FPGA
```

### 2. Базовый запуск (полный flow: Yosys → VPR → OpenFPGA Shell)
```bash
# Запуск в интерактивном режиме с логами
docker compose run --rm openfpga bash -c "
  cd /opt/openfpga && \
  python3 openfpga_flow/scripts/run_fpga_task.py \
    /opt/openfpga/openfpga_flow/tasks/memristor_fir \
    --show_thread_logs
"
```

### 3. Тестовый прогон (dry-run, без выполнения)
```bash
docker compose run --rm openfpga bash -c "
  cd /opt/openfpga && \
  python3 openfpga_flow/scripts/run_fpga_task.py \
    /opt/openfpga/openfpga_flow/tasks/memristor_fir \
    --test_run
"
```

### 4. Запуск с сохранением артефактов
```bash
# Результаты автоматически сохраняются в ./runs/ на хосте
# благодаря volume mount в docker-compose.yml

# После завершения проверьте результаты:
ls -la runs/*/vpr_arch_mem/fir_top/DEFAULT/
```

### 5. Очистка старых запусков
```bash
# Удалить все run* директории
docker compose run --rm openfpga bash -c "
  cd /opt/openfpga/openfpga_flow/tasks/memristor_fir && \
  python3 openfpga_flow/scripts/run_fpga_task.py \
    /opt/openfpga/openfpga_flow/tasks/memristor_fir \
    --remove_run_dir all
"
```

---

## Конфигурация бенчмарков

### Используемый бенчмарк (по умолчанию): 16-битный счетчик
```ini
# config/task.conf
[BENCHMARKS]
bench0 = ${PATH:OPENFPGA_PATH}/openfpga_flow/benchmarks/ubm/simple_registers/counters/counterup16_1clk_posedge_sync_resetp/counterup16_1clk_posedge_sync_resetp.v

[SYNTHESIS_PARAM]
bench0_top = counterup16_1clk_posedge_sync_resetp
bench0_openfpga_pin_constraints_file = ${PATH:TASK_DIR}/config/pin_constraints_rst.xml
```

### Переключение на FIR фильтр (мемристорный)
```ini
# В config/task.conf раскомментируйте:
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

> ⚠️ **Примечание**: FIR бенчмарк с массивами требует VPR архитектуру с поддержкой unidir сегментов. Текущая версия VPR 9.0 в контейнере может вызывать segfault на сложных BLIF. Используйте счетчик для проверки работоспособности flow.

---

## Архитектуры

| Архитектура | VPR файл | OpenFPGA файл | Описание |
|-------------|----------|---------------|----------|
| **k4_N4 (стандартная)** | `k4_N4_tileable_40nm.xml` | `k4_N4_40nm_cc_openfpga.xml` | 4-LUT, N=4, работающая база |
| **Мемристорная (custom)** | `vpr_arch_mem.xml` | `openfpga_arch_mem.xml` | 4-LUT + RRAM свитчи (эксперимент) |

---

## Полезные команды

### Просмотр логов последнего запуска
```bash
docker compose run --rm openfpga bash -c "
  cat /opt/openfpga/openfpga_flow/tasks/memristor_fir/runs/latest/vpr_stdout.log
"
```

### Проверка таймингов
```bash
docker compose run --rm openfpga bash -c "
  cat /opt/openfpga/openfpga_flow/tasks/memristor_fir/runs/latest/report_timing.setup.rpt | head -50
"
```

### Просмотр сгенерированного Verilog
```bash
docker compose run --rm openfpga bash -c "
  ls -la /opt/openfpga/openfpga_flow/tasks/memristor_fir/runs/latest/SRC/
  cat /opt/openfpga/openfpga_flow/tasks/memristor_fir/runs/latest/SRC/fpga_top.v | head -100
"
```

### Интерактивная оболочка в контейнере
```bash
docker compose run --rm -it openfpga bash
# Внутри контейнера:
cd /opt/openfpga/openfpga_flow/tasks/memristor_fir
# Ручное исследование файлов
```

---

## Troubleshooting

### Ошибка: "Inconsistent block data sizes"
- **Причина**: VPR 9.0 несовместимость с генерируемым BLIF для сложных дизайнов (FIR с массивами)
- **Решение**: Используйте простые бенчмарки (счетчики) или обновите VPR до версии с фиксом

### Ошибка: "libyosys.so: cannot open shared object file"
- **Причина**: LD_LIBRARY_PATH не установлен
- **Решение**: Уже исправлено в `docker-compose.yml` через `environment: LD_LIBRARY_PATH`

### Ошибка: "permission denied" на volume mounts
```bash
# На Linux может потребоваться:
sudo chown -R $USER:$USER ~/Memristor_FPGA
# Или запуск с --user root (в docker-compose.yml)
```

### Контейнер не запускается / OOM
```bash
# Увеличьте лимиты Docker:
# Docker Desktop → Settings → Resources → Memory: 8-16 GB
# На Linux: проверьте docker system df, очистите неиспользуемые образы
docker system prune -a
```

### Проблемы с путями Windows ↔ Linux
- В `task.conf` используются `${PATH:TASK_DIR}` и `${PATH:OPENFPGA_PATH}` — они корректно резолвятся внутри контейнера
- Пути в `docker-compose.yml` указаны в формате хоста (Windows), Docker Desktop автоматически мапит их

---

## Результаты генерации

После успешного завершения в `runs/latest/` будут:

| Файл | Описание |
|------|----------|
| `SRC/fpga_top.v` | Топ-уровень Verilog FPGA ткани |
| `SRC/sub_module/*.v` | Примитивы: LUT, MUX, FF, wires, memories |
| `fabric_bitstream.bit` | Битстрим конфигурации (plain text) |
| `fabric_independent_bitstream.xml` | Архитектурно-независимый битстрим |
| `fabric_hierarchy.txt` | Иерархия модулей ткани |
| `*.blib` | BLIF нетлисты (pre/post synthesis) |
| `*.net` | VPR нетлисты |
| `*.place`, `*.route` | Placement & Routing файлы |
| `report_timing.setup/hold.rpt` | Static Timing Analysis отчеты |
| `vpr_stat.result` | Ключевые метрики (CLB, IO, channel width, timing) |

---

## Следующие шаги для исследования

1. **Сравнение архитектур**: Запустите flow с `arch0 = vpr_arch_mem.xml` и сравните `vpr_stat.result`
2. **Power analysis**: Включите `power_analysis = true` в `[GENERAL]`
3. **Spice export**: `spice_output = true` для экспорта SPICE нетлистов
4. **Channel width sweep**: Добавьте `[SCRIPT_PARAM_MIN_ROUTE_CHAN_WIDTH]` с разными `vpr_route_chan_width`
5. **Мемристорные параметры**: Модифицируйте `R`, `Tdel` в `switchlist` для моделирования 1кОм / 4кОм / 20кОм RRAM

---

## Ссылки

- **OpenFPGA репозиторий**: https://github.com/lnis-uofu/OpenFPGA
- **VTR (Verilog-to-Routing)**: https://github.com/verilog-to-routing/vtr-verilog-to-routing
- **Yosys**: https://github.com/YosysHQ/yosys
- **Docker Hub образ**: https://ghcr.io/lnis-uofu/openfpga-master
- **Документация OpenFPGA**: https://openfpga.readthedocs.io/