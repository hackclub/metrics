# metrics

## Plotting Slack Usage

We've written a really nifty script in [`plot.sh`](plot.sh) that plots the
activity in our Slack. It expects you to have
[`gnuplot`](http://www.gnuplot.info/) installed and to be on Linux.

Once you're ready to run it, just run the following command while in the root of
this repository:

    $ ./plot.sh

And you should get a plot that resembles the following:

![](https://i.imgur.com/JYW5KH3.png)
