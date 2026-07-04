# Fig. 9: Q-Learning vs P-MARL, 48 cities
# Uses prize.dat and distance.dat
# Outputs total_prize.pdf and total_distance.pdf

set terminal pdfcairo enhanced font "Times-Roman,18" size 4.2,3.0

set style data histograms
set style histogram errorbars gap 1 lw 1.2
set style fill pattern border -1
set boxwidth 0.75

set border lw 1.3
set grid ytics lt 0 lw 0.5

set xtics font "Times-Roman,16"
set ytics font "Times-Roman,16"
set xlabel "Budget (miles)" font "Times-Roman,20"
set key top left font "Times-Roman,15" spacing 1.0 samplen 1.5

# normal spacing/indentation
set lmargin 12
set rmargin 2
set tmargin 1
set bmargin 4

# ---- Fig. 9(a): Total Prize ----
set output "total_prize.pdf"

set ylabel "Prize Collected" font "Times-Roman,20"
set yrange [0:3000]
set ytics 500

plot 'prize.dat' using 2:3:xtic(1) title "Q-Learning" fs pattern 1, \
     ''          using 4:5        title "P-MARL"    fs pattern 4

# ---- Fig. 9(b): Total Distance ----
set output "total_distance.pdf"

set ylabel "Distance (miles)" font "Times-Roman,20"
set yrange [3000:10000]
set ytics 1000

plot 'distance.dat' using 2:3:xtic(1) title "Q-Learning" fs pattern 1, \
     ''             using 4:5        title "P-MARL"    fs pattern 4

set output
