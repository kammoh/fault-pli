onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {SayehTest top-level}
add wave -noupdate -format Logic -height 15 /SayehTest/clk
add wave -noupdate -format Logic -height 15 /SayehTest/ExternalReset
add wave -noupdate -format Logic -height 15 /SayehTest/ReadMem
add wave -noupdate -format Logic -height 15 /SayehTest/WriteMem
add wave -noupdate -format Logic -height 15 /SayehTest/ReadIO
add wave -noupdate -format Logic -height 15 /SayehTest/WriteIO
add wave -noupdate -format Logic -height 15 /SayehTest/MemDataready

add wave -format Literal -height 15 -radix hexadecimal /SayehTest/Databus_in
add wave -format Literal -height 15 -radix decimal /SayehTest/Addressbus
add wave -format Literal -height 15 -radix hexadecimal /SayehTest/Databus_out

add wave -format Logic -height 15 /SayehTest/U1/*

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 314
configure wave -valuecolwidth 136
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {0 ps} {1646 ns}

