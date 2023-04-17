# Глава 3. Создание приложений RISC-V

В этой главе мы узнаем, как использовать популярные наборы инструментов компилятора (как LLVM, так и GCC) для создания приложений RISC-V, а также как запускать приложения на симуляторах и эмуляторах. В этой главе представлены вводные материалы, которые помогут вам получить практический опыт создания и запуска приложений RISC-V. Поскольку инструменты и их зависимости часто меняются, некоторые аспекты этого курса могут работать некорректно до тех пор, пока не будет произведено обновление курса. Помня об этом, мы приводим ссылки на официальные списки рассылки, репозитории GitHub и веб-сайты. Они могут оказаться весьма полезными, если вы захотите углубиться в какие-либо области разработки RISC-V.

В этой главе мы обсудим:

- введение в инструментарий RISC-V;
- где скачать наборы инструментов и симулятор;
- создание приложений с помощью этого набора инструментов;
- запуск приложений на симуляторе;
- запуск приложений на эмуляторе;
- полезные справочные материалы.

## Введение в инструментарий RISC-V

Есть два наиболее популярных набора инструментов RISC-V.

1. GNU RISC-V
2. LLVM RISC-V

Оба набора инструментов предоставляют оптимизирующий компилятор, ассемблер, компоновщик и другие различные инструменты для создания приложений, работающих на машинах RISC-V. Официальный [репозиторий RISC-V на GitHub](https://github.com/riscv-collab/riscv-gcc) предоставляет исходный код для набора инструментов `riscv-gnu`, набор инструментов в собранном виде можно скачать по [ссылке](https://github.com/riscv-collab/riscv-gnu-toolchain). Компилятор RISC-V обычно используется в качестве кросс-компилятора, поскольку многие процессоры RISC-V используются для встраиваемых приложений с низким энергопотреблением. В настоящее время кросс-компиляторы RISC-V можно запускать только на [целевых платформах ELF](https://en.wikipedia.org/wiki/Comparison_of_executable_file_formats) таких, как Linux-машины.

Инструментарий RISC-V LLVM недоступен у сторонних поставщиков, но его можно собрать из исходников, загрузив проект [llvm-project](https://github.com/llvm/llvm-project) с открытым кодом. Позже будет описан простой способ использования набора инструментов llvm с gnu sysroot.

Симулятор RISC-V можно загрузить из официального репозитория RISC-V на GitHub: [riscv/riscv-isa-sim: Spike, симулятор RISC-V ISA](https://github.com/riscv-software-src/riscv-isa-sim). Хотя платы RISC-V легко доступны у нескольких производителей, начать разработку RISC-V проще начать, используя симуляторы.

## Создание приложений с помощью набора инструментов

Для создания приложения для RISC-V использование инструментальной цепочки кросс-компилятора не отличается от любой другой системы разработки на основе кросс-компилятора. Требуется две вещи:

- инструментарий компилятора
- sysroot

В [первой главе](%D0%93%D0%BB%D0%B0%D0%B2%D0%B0%201%20%D0%98%D0%BD%D1%81%D1%82%D1%80%D1%83%D0%BC%D0%B5%D0%BD%D1%82%D0%B0%D1%80%D0%B8%D0%B8%CC%86%20%D0%BA%D0%BE%D0%BC%D0%BF%D0%B8%D0%BB%D1%8F%D1%82%D0%BE%D1%80%D0%B0%20aa8b22dfa5df49bbab35306db2acc792.md) мы описали инструментарий компилятора и `sysroot`. Прежде чем научиться создавать приложения с помощью набора инструментов RISC-V, мы хотели бы представить интересное соглашение об именовании, которое используется для кросс-компиляторов.

### Соглашение об именовании компиляторов

Когда вы загружаете инструментарий GCC, в каталоге `bin` вы найдете двоичный файл `riscv64-unknown-elf-gcc`. Это тот же самый компилятор GCC со встроенной информацией о `sysroot` и платформе. Это соглашение — называть кросс-компиляторы таким образом. Обычно для именования используется формат `arch-vendor-os-abi`. Так, `riscv64-unknown-elf-gcc` означает, что это кросс-компилятор для RISC-V 64 bit, и он будет генерировать двоичный файл `elf`, который может работать, например, на машинах Linux. Отличный справочник по соглашениям об именовании можно найти [здесь](http://web.eecs.umich.edu/~prabal/teaching/eecs373-f12/notes/notes-toolchain.pdf). В случаях, когда имя компилятора не содержит целевого триплета, для его получения можно использовать флаг `-dumpmachine`:

```bash
gcc -dumpmachine
# x86_64-linux-gnu
```

Имея под рукой компилятор `riscv64-unknown-elf-gcc`, файл можно скомпилировать следующими способами:

```bash
riscv64-unknown-elf-gcc -O2 -o a.out hello.c
```

```bash
riscv64-unknown-elf-gcc -O2 hello.c -mabi=lp64d -march=rv64ifd
```

Флаг `-march` используется для указания целевой субархитектуры, для которой будет сгенерирована сборка. Флаг `-mabi` используется для указания моделей данных. Более подробную информацию о моделях данных можно найти в [этом разделе](https://en.wikipedia.org/wiki/64-bit_computing#64-bit_data_models) Википедии о 64-битовых вычислениях.

С помощью инструментария llvm двоичный файл может быть собран аналогичным образом. Предполагается, что `sysroot` находится в каталоге `riscv64-unknown-elf`:

```bash
clang test.c -c --sysroot riscv64-unknown-elf -target
# riscv64-unknown-elf -march=rv64ifd
```

Приложения RISC-V можно запускать как на устройствах, так и на симуляторах или эмуляторах. Мы кратко обсудим, как запустить приложение на симуляторе, а также на эмуляторе.

## Запуск приложений на симуляторе Spike

Одним из самых удобных способов запуска небольших приложений является использование симулятора RISC-V. Шаги по сборке и установке достаточно просты. Для этого вам понадобятся следующие зависимости:

1. Linux-машина — создание образа Linux на других машинах нетривиально, поэтому для начала рекомендуется использовать Linux-машину.
2. набор инструментов RISC-V: [https://github.com/riscv-software-src](https://github.com/riscv-software-src)
3. Spike, симулятор RISC-V: [https://github.com/riscv-software-src/riscv-isa-sim](https://github.com/riscv-software-src/riscv-isa-sim)
4. pk, прокси-ядро RISC-V: [https://github.com/riscv-software-src/riscv-pk](https://github.com/riscv-software-src/riscv-pk)

Инструкции по запуску простого приложения `hello-world` на симуляторе Spike приведены в [README](https://github.com/riscv-software-src/riscv-isa-sim#compiling-and-running-a-simple-c-program) репозитория симулятора. Чтобы установить прокси-ядро, следуйте инструкциям в [README](https://github.com/riscv-software-src/riscv-pk#build-steps) репозитория `pk`. Для удобства вы можете установить и `spike`, и `pk` в тот же каталог, что и каталог инструментария `riscv64`, указав путь к нему в качестве префикса установки для обоих.

## Запуск приложений на эмуляторе

Запуск приложения RISC-V на эмуляторе обеспечивает большую гибкость, чем на симуляторе, но этапы установки требуют больше усилий. Чтобы запустить приложение RISC-V на эмуляторе, необходимо иметь следующие зависимости:

1. Linux-машина — создание образа Linux на других машинах нетривиально, поэтому для начала рекомендуется использовать Linux-машину.
2. набор инструментов RISC-V: [https://github.com/riscv-software-src](https://courses.edx.org/xblock/Running%20an%20RISC-V%20application%20on%20an%20emulator%20gives%20you%20more%20flexibility%20but%20the%20installation%20steps%20are%20more%20involved.%20In%20order%20to%20run%20a%20RISC-V%20application%20on%20an%20emulator%20you%20need%20to%20have%20the%20following%20dependencies.%20A%20Linux%20machine.%20Building%20a%20Linux%20image%20on%20non-Linux%20machines%20is%20non-trivial%20so%20it%20is%20recommended%20you%20have%20a%20Linux%20machine%20to%20begin%20with.%20RISC-V%20toolchain%20(https://github.com/riscv-software-src)%20QEMU%20(git%20clone%20--depth%201%20--branch%20v5.0.0%20https://github.com/qemu/qemu)%20Linux%20(git%20clone%20--depth%201%20--branch%20v5.4%20https://github.com/torvalds/linux)%20Busybox%20(git%20clone%20--depth%201%20git://git.busybox.net/busybox)%20%20The%20branches%20listed%20above%20are%20suggested%20versions%20and%20that%20may%20change%20frequently.%20You%20can%20choose%20other%20branches%20as%20well.%20The%20documentation%20above%20may%20become%20stale%20if%20any%20of%20the%20dependencies%20have%20breaking%20changes.%20Check%20https://risc-v-getting-started-guide.readthedocs.io/en/latest/linux-qemu.html%20to%20see%20the%20latest%20supported%20versions.%20If%20this%20documentation%20does%20not%20work,%20be%20sure%20to%20ask%20in%20the%20linux-riscv%20mailing%20list.%20%20Build%20QEMU%20with%20the%20RISC-V%20target:%20cd%20qemu%20./configure%20--target-list=riscv64-softmmu%20--prefix=/path/to/keep/qemu%20make%20-j%20$(nproc)%20make%20install%20%20Build%20Linux%20for%20the%20RISC-V%20target:%20cd%20linux%20make%20ARCH=riscv%20CROSS_COMPILE=riscv64-unknown-linux-gnu-%20defconfig%20make%20ARCH=riscv%20CROSS_COMPILE=riscv64-unknown-linux-gnu-%20-j%20$(nproc)%20%20Make%20sure%20to%20have%20the%20prefix%20of%20the%20cross%20compiler%20match%20from%20your%20toolchain.%20In%20the%20above%20example%20the%20gcc%20compiler%20is%20riscv64-unknown-linux-gnu-gcc%20so%20the%20CROSS_COMPILE%20flag%20is%20riscv64-unknown-linux-gnu-%20%20Build%20the%20busybox%20%20cd%20busybox%20CROSS_COMPILE=riscv64-unknown-linux-gnu-%20make%20defconfig%20CROSS_COMPILE=riscv64-unknown-linux-gnu-%20make%20-j%20$(nproc)%20%20To%20run%20linux%20image%20on%20QEMU%20run%20sudo%20/path/to/keep/qemu/bin/qemu-system-riscv64%20-nographic%20-machine%20virt%20/%20%20%20%20%20%20-kernel%20/path/to/linux/image%20-append%20%22root=/dev/vda%20ro%20console=ttyS0%22%20/%20%20%20%20%20%20-drive%20file=busybox,format=raw,id=hd0%20/%20%20%20%20%20%20-device%20virtio-blk-device,drive=hd0%20%20You%20can%20also%20run%20bare%20metal%20app%20on%20QEMU%20like%20this%20/path/to/keep/qemu/bin/qemu-system-riscv64%20-nographic%20-machine%20virt%20-kernel%20/path/to/binary%20-bios%20none%20%20For%20additional%20QEMU%20configurations%20for%20RISC-V,%20checkout%20the%20official%20documentation.%20In%20addition%20to%20simulators%20and%20emulators,%20RISC-V%20applications%20can%20be%20run%20on%20virtual%20machines%20as%20well%20as%20commercially%20available%20development%20boards.%20Additional%20documentation%20to%20debug%20bare%20metal%20issues%20can%20be%20found%20here.%20You%20can%20install%20the%20RISC-V%20virtual%20machine%20as%20documented%20here.)
3. QEMU: `git clone --depth 1 --branch v5.0.0 https://github.com/qemu/qemu`
4. Linux: `git clone --depth 1 --branch v5.4 https://github.com/torvalds/linux`
5. Busybox: `git clone --depth 1 git://git.busybox.net/busybox`

Перечисленные выше ветки репозиториев являются предлагаемыми версиями, они могут часто меняться. Вы можете выбрать и другие ветки. Приведенная выше документация может устареть, если в какой-либо из зависимостей произойдут изменения. Проверьте страницу документации [Running 64- and 32-bit RISC-V Linux on QEMU documentation page](https://risc-v-getting-started-guide.readthedocs.io/en/latest/linux-qemu.html), чтобы узнать последние поддерживаемые версии. Если эта документация не работает, обязательно спросите в списке рассылки [linux-riscv](http://lists.infradead.org/pipermail/linux-riscv/).

#### Сборка QEMU для RISC-V

```bash
cd qemu
./configure --target-list=riscv64-softmmu --prefix=/path/to/keep/qemu
make -j $(nproc)
make install
```

#### Сборка Linux для целевой системы RISC-V

```bash
cd linux
make ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu- defconfig
make ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu- -j $(nproc)
```

Убедитесь, что префикс кросс-компилятора совпадает с префиксом вашего набора инструментов. В приведенном выше примере компилятор GCC — `riscv64-unknown-linux-gnu-gcc`, поэтому флаг `CROSS_COMPILE` — `riscv64-unknown-linux-gnu-`.

#### Сборка busybox

```bash
cd busybox
CROSS_COMPILE=riscv64-unknown-linux-gnu- make defconfig
CROSS_COMPILE=riscv64-unknown-linux-gnu- make -j $(nproc)
```

#### Запуск образа Linux в QEMU

```bash
sudo /path/to/keep/qemu/bin/qemu-system-riscv64 -nographic -machine
virt \
     -kernel /path/to/linux/image -append "root=/dev/vda ro
console=ttyS0" \
     -drive file=busybox,format=raw,id=hd0 \
     -device virtio-blk-device,drive=hd0
```

#### Запуск приложения на QEMU на “голом железе”

```bash
/path/to/keep/qemu/bin/qemu-system-riscv64 -nographic -machine virt
-kernel /path/to/binary -bios none
```

Дополнительные конфигурации QEMU для RISC-V можно найти в [официальной документации](https://wiki.qemu.org/Documentation/Platforms/RISCV). Помимо симуляторов и эмуляторов, приложения RISC-V можно запускать на виртуальных машинах, а также на имеющихся в продаже платах для разработки. Дополнительную документацию по отладке проблем с «голым железом» можно найти [здесь](https://embeddedinn.xyz/articles/tutorial/Adding-a-custom-peripheral-to-QEMU/). Вы можете установить виртуальную машину RISC-V, как описано в документации [здесь](https://wiki.debian.org/RISC-V).

## Справочные материалы

- [Tech: Toolchain & Runtime Subcommittee mailing list](mailto:tech-toolchain-runtime@lists.riscv.org)
- [кросс-компилятор GCC](https://wiki.osdev.org/GCC_Cross-Compiler)
- [64-битовые модели данных](https://en.wikipedia.org/wiki/64-bit_computing#64-bit_data_models)
- [архив linux-riscv](https://en.wikipedia.org/wiki/64-bit_computing#64-bit_data_models)
- [Running 64- and 32-bit RISC-V Linux on QEMU](https://risc-v-getting-started-guide.readthedocs.io/en/latest/linux-qemu.html)
- [Qemu: Документация/Платформы/RISCV](https://wiki.qemu.org/Documentation/Platforms/RISCV)
- [Debian — RISC-V Wiki](https://wiki.debian.org/RISC-V)

**Платы RISC-V**
Страница [RISC-V Exchange](https://riscv.org/exchange/) представляет собой коллекцию доступного физического оборудования в экосистеме RISC-V. Этот список курируется сообществом.

**Ядра RISC-V**
Страница [RISC-V Exchange: Cores & SoCs](https://riscv.org/exchange/?_sft_exchange_category=core,cores) представляет собой коллекцию доступных IP-ядер однокристальных систем в экосистеме RISC-V.

**Поставщики наборов инструментов и другого аппаратного и программного обеспечения:**

- [RISC-V Software Collaboration](https://github.com/riscv-collab)
- [sifive/freedom-tools](https://github.com/sifive/freedom-tools/releases)
- [lowRISC](https://github.com/lowRISC)
- [stnolting/riscv-gcc-prebuilt](https://github.com/stnolting/riscv-gcc-prebuilt)
- [SiFive/Software](https://www.sifive.com/software)