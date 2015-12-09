#!/bin/sh

USER_STATS=$(mktemp)
SUM_STATS=$(mktemp)

# Invert columns and rows
#
# Users	2015-12-08	2015-12-09	2015-12-10
# john	10	15	20
# sally	15	28	40
# zach	8	10	12
#
#          |
#          v
#
# Users	john	sally	zach
# 2015-12-08	10	15	8
# 2015-12-09	15	28	10
# 2015-12-10	20	40	12
invert_table() {
  awk '
{
  for (i=1; i<=NF; i++)  {
    a[NR,i] = $i
  }
}
NF>p { p = NF }
END {
  for(j=1; j<=p; j++) {
    str=a[1,j]
    for(i=2; i<=NR; i++){
      str=str"\t"a[i,j];
    }
    print str
  }
}' $@
}

# Sum each column to get totals for each day and construct a TSV with just the
# totals in it

# Add the date headers to $SUM_STATS
head -n 1 slack_stats.tsv | cut -f2- >> $SUM_STATS

# Calculate the totals for each date and add them to $SUM_STATS
sed -e 's/\t\t/\t0\t/g' -e 's/\t\t/\t0\t/g' slack_stats.tsv |
  tail -n+2 |
  cut -f 2- |
  awk '
{
  for (i=1; i<=NF; i++) {
    sum[i] += $i
  }
}
END {
  for (i in sum) {
    print sum[i]
  }
}' |
  paste -sd'\t' >> $SUM_STATS

# Invert the $SUM_STATS table
tmp_sum=$(mktemp)
invert_table $SUM_STATS > $tmp_sum
mv $tmp_sum $SUM_STATS

invert_table slack_stats.tsv > $USER_STATS

gnuplot --persist <<EOF
set xdata time
set timefmt '%Y-%m-%dT%H:%M%SZ'
set nokey

set multiplot layout 2, 1 title "Slack Usage Statistics" font ",14"
set tmargin 4

set title "All Time Messages"
plot '$SUM_STATS' using 1:2 with lines

set title "User Messages"
nc = "`awk 'NR == 1 { print NF; exit }' $USER_STATS`"
plot for [i=2:nc] '$USER_STATS' using 1:i with lines
EOF

rm $USER_STATS
rm $SUM_STATS
