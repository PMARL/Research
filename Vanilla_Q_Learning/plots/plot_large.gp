# Fig. 10: Q-Learning vs P-MARL, 620 cities
# Uses prize_large.dat and runtime_large.dat
# Outputs total_prize_large.pdf and total_runtime_large.pdf

set terminal pdfcairo enhanced font "Times-Roman,18" size 4.2,3.0

set style data histograms
set style histogram errorbars gap 1 lw 1.2
set style fill pattern border -1
set boxwidth 0.75

set border lw 1.3
set grid ytics lt 0 lw 0.5

set xtics font "Times-Roman,16"
set ytics font "Times-Roman,16"
set xlabel "Budget (units)" font "Times-Roman,20"
set key top left font "Times-Roman,15" spacing 1.0 samplen 1.5

set lmargin 12
set rmargin 2
set tmargin 1
set bmargin 4

# ---- Fig. 10(a): Total Prize ----
set output "total_prize_large.pdf"

set ylabel "Prize Collected" font "Times-Roman,20"
set yrange [0:30000]
set ytics 5000

plot 'prize_large.dat' using 2:3:xtic(1) title "Q-Learning" fs pattern 1, \
     ''                using 4:5        title "P-MARL"    fs pattern 4

# ---- Fig. 10(b): Total Runtime ----
set output "total_runtime_large.pdf"

set ylabel "Runtime (s)" font "Times-Roman,20"
set yrange [0:160]
set ytics 20

plot 'runtime_large.dat' using 2:3:xtic(1) title "Q-Learning" fs pattern 1, \
     ''                  using 4:5        title "P-MARL"    fs pattern 4

set output
