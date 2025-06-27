@echo off
echo Cleaning up .out, .vcd files and results.txt...
del /f /q *.out *.vcd results.txt pc.txt
echo Done.
iverilog -o a.out *.v
vvp a.out 