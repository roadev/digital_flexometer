require 'rinruby'

a = RinRuby.new

wt = [1,2,3]
a.eval("wt <- c(#{wt.join(",")})")
mpg = [2,4,7]
a.eval("mpg <- c(#{wt.join(",")})")
a.eval("mpg<- c(#{mpg.join(",")})")
a.eval("png('sample.png')")
a.eval("plot(wt, mpg)")
a.eval("dev.off()")

# a.plot(wt, mpg, main="Scatterplot Example",
#   	xlab="Car Weight ", ylab="Miles Per Gallon ", pch=19)
