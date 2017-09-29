onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L secureip -L blk_mem_gen_v8_3_1 -L xil_defaultlib -lib xil_defaultlib xil_defaultlib.data_ram3

do {wave.do}

view wave
view structure
view signals

do {data_ram3.udo}

run -all

quit -force