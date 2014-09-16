library("ggplot2", lib.loc="/Library/Frameworks/R.framework/Versions/3.0/Resources/library")
library("lubridate", lib.loc="/Library/Frameworks/R.framework/Versions/3.0/Resources/library")
options(java.parameters="-Xmx2g")
library(rJava)
library(RJDBC)

jdbcDriver <- JDBC(driverClass="oracle.jdbc.OracleDriver", classPath="/Library/Java/JavaVirtualMachines/jdk1.7.0_67.jdk/Contents/Home/ojdbc6.jar")

# In the following, use your username and password instead of "CS347_prof", "orcl_prof" once you have an Oracle account
possibleError <- tryCatch(
  jdbcConnection <- dbConnect(jdbcDriver, "jdbc:oracle:thin:@128.83.138.158:1521:orcl", "C##cs347_nos98", "orcl_nos98"),
error=function(e) e
)
if(!inherits(possibleError, "error")){
  accidents <- dbGetQuery(jdbcConnection, "select * from accident")
  dbDisconnect(jdbcConnection)
}
head(accidents)

# It's not the weather that's doing this
# 1 is clear, 2 is rainy
ggplot(data = (accidents)) + geom_histogram(aes_string(x = 'WEATHER')) + xlim(0, 8)

# Most accidents happen on weekend, but not as many as we expected.
ggplot(data = (accidents)) + geom_histogram(aes_string(x = 'DAY_WEEK')) 

# lots of accidents in the early morning (leaving bars), but 
# more so when people are coming home from work (but not heading to work).
ggplot(data = (accidents)) + geom_histogram(aes_string(x = 'HOUR')) + xlim(0, 25)

# recordings happen mostly at the 5 minute marks - human error in the data
ggplot(data = (accidents)) + geom_histogram(aes_string(x = 'MINUTE')) + xlim(0, 60)


# People crash waaaaay more on the east coast...there are no people in the midwest
ggplot(accidents) + geom_point(aes(x=LONGITUD,y=LATITUDE)) + coord_map(project="mercator") + xlim(-130, -60) + ylim(20, 55)