# Техническое задание (отчёт о выполненных работах)

## Тема
Запуск проекта «Мемристорный FPGA на базе OpenFPGA» (Yosys → VPR → OpenFPGA Shell) в виртуальной машине VMware с Ubuntu 24.04 без использования Docker и Docker Compose.

## 1. Назначение и цели
- **Назначение**: обеспечить нативный (без контейнеров) запуск OpenFPGA flow для проекта Memristor_FPGA на Ubuntu 24.04 в VMware Workstation.
- **Цели**:
  1. Исключить зависимости от Docker Engine / Docker Compose.
  2. Сохранить эквивалентность окружения, заданного в `docker-compose.yml` (рабочий каталог, `LD_LIBRARY_PATH`, монтирования файлов).
  3. Получить воспроизводимую последовательность команд для развёртывания задачи и запуска flow.

## 2. Объект работ
Проект `Memristor_FPGA` — исследование FPGA-ткани с RRAM (memristor) элементами коммутации:
- RTL-бенчмарки: `fir.v` (8-тактный FIR-фильтр с RRAM-хранением коэффициентов), `rram_1t1r.v` (модель 1T1R RRAM), `rram_ccff.v` (конфигурационный FF);
- архитектуры: `vpr_arch_mem.xml` / `openfpga_arch_mem.xml` (мемристорные свитчи 1/4/20 кОм), базовая `k4_N4_tileable_40nm.xml`;
- конфигурация flow: `config/task.conf`, пины `config/pin_constraints_*.xml`;
- стендовый бенчмарк проверки работоспособности: 16-битный счётчик `counterup16_1clk_posedge_sync_resetp`.

Исходно проект запускался только через образ `ghcr.io/lnis-uofu/openfpga-master` с bind-монтированиями:
корень проекта → `openfpga_flow/tasks/memristor_fir`, `rram_1t1r.v`/`rram_ccff.v` → `openfpga_flow/openfpga_cell_library/verilog/`.

## 3. Выполненные работы

### 3.1. Анализ проекта и среды
- Изучены `docker-compose.yml`, `config/task.conf`, архитектуры и результаты прогонов (`run001…run034`).
- Установлено, что flow полностью обеспечивается исходным репозиторием OpenFPGA (VPR 9.0, Yosys, OpenFPGA Shell собираются из исходников); доп. системные Yosys/VPR не требуются.
- Определены обязательные элементы нативного окружения, эквивалентные контейнеру: переменные из `openfpga.sh` (`OPENFPGA_PATH` и пр.) и `LD_LIBRARY_PATH=<repo>/build/yosys:<repo>/build/openfpga`.

### 3.2. Установка зависимостей (Ubuntu 24.04)
- Установлен пакетный набор сборки из официальной инструкции OpenFPGA для Ubuntu 24.04 (build-essential, cmake, flex/bison, readline/editline, tcl/tk-dev, eigen, omp, xml++, iverilog и др.).
- Установлены Python-зависимости flow-скриптов: `envyaml`, `humanize`, `coloredlogs`, `pyverilog` (с флагом `--break-system-packages` из-за PEP 668 в Ubuntu 24.04).

### 3.3. Сборка OpenFPGA
- Клонирован `https://github.com/lnis-uofu/OpenFPGA` с подмодулями; сборка `make all -j$(nproc)` (Yosys, ABC, VPR, OpenFPGA).
- Проверка корректности сборки: задача `compilation_verification`.

### 3.4. Перенос и развёртывание проекта
- Файлы проекта перенесены из Windows (PowerShell: `Compress-Archive` + `scp`) в ВМ; проект размещён в `/home/kirill/OpenFPGA/Memristor_FPGA`.
- Роль bind-монтирований docker-compose заменена копированием: `rram_1t1r.v`, `rram_ccff.v` скопированы в `openfpga_flow/openfpga_cell_library/verilog/`.
- Каталог проекта использован как директория задачи напрямую (скрипт `run_fpga_task.py` находит задачу по относительному пути от корня репозитория; `TASK_DIR`/`OPENFPGA_PATH` резолвятся автоматически).

### 3.5. Команды запуска (итоговые)
```bash
cd /home/kirill/OpenFPGA
source openfpga.sh
export LD_LIBRARY_PATH=$OPENFPGA_PATH/build/yosys:$OPENFPGA_PATH/build/openfpga:$LD_LIBRARY_PATH
cp Memristor_FPGA/rram_1t1r.v Memristor_FPGA/rram_ccff.v openfpga_flow/openfpga_cell_library/verilog/
python3 openfpga_flow/scripts/run_fpga_task.py Memristor_FPGA --test_run          # сухой прогон
python3 openfpga_flow/scripts/run_fpga_task.py Memristor_FPGA --show_thread_logs  # полный запуск
```

### 3.6. Устранённые дефекты
| Дефект | Причина | Решение |
|---|---|---|
| `IsADirectoryError: [Errno 21] 'latest'` при создании run-директории | symlink `latest`, ставший обычной папкой при переносе zip из Windows; `os.remove()` не удаляет каталоги | `rm -rf Memristor_FPGA/latest` перед прогоном; опциональная правка скрипта: `os.remove("latest")` → `shutil.rmtree("latest")` |

## 4. Результаты
- Flow Yosys → VPR → OpenFPGA Shell запускается нативно на Ubuntu 24.04 (VMware) без Docker.
- Артефакты прогонов формируются в `Memristor_FPGA/runNNN/<arch>/<top>/DEFAULT/`: `SRC/` (Verilog ткани), `fabric_bitstream.bit`, отчёты STA `report_timing.*.rpt`, метрики `vpr_stat.result`, `latest` (symlink).
- Управление прогонами: `--test_run` (проверка команд), `--remove_run_dir all` (очистка).

## 5. Требования к ВМ (подтверждённые)
- RAM ≥ 8 ГБ (рекомендуется 16), CPU ≥ 2 ядра, диск ≥ 20 ГБ свободно; x86_64.
- Для FIR-конфигурации с массивами — ограничения VPR 9.0 (возможный segfault на сложных BLIF), базовая проверка — на счётчике.

## 6. Ссылки
- OpenFPGA: https://github.com/lnis-uofu/OpenFPGA
- Документация по сборке: https://openfpga.readthedocs.io/en/master/tutorials/getting_started/compile/
- `RUN_GUIDE.md` — руководство по Docker-запуску (сохранено без изменений)
