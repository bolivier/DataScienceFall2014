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
ggplot(data = subset(accidents, WEATHER1 <= 8)) + geom_histogram(aes_string(x = 'WEATHER1')) + scale_x_discrete(limits = c("Clear", "Rain", "Hail", "Snow", "Fog", "Crosswind", "Sand Storm", "other"))

# Most accidents happen on weekend, but not as many as we expected.
ggplot(data = (accidents)) + geom_histogram(aes_string(x = 'DAY_WEEK')) 

# lots of accidents in the early morning (leaving bars), but 
# more so when people are coming home from work (but not heading to work).
ggplot(data = (accidents)) + geom_histogram(aes_string(x = 'HOUR')) + xlim(0, 25)

# recordings happen mostly at the 5 minute marks - human error in the data
ggplot(data = (accidents)) + geom_histogram(aes_string(x = 'MINUTE')) + xlim(0, 60)

# People crash waaaaay more on the east coast...there are no people in the midwest
ggplot(accidents) + geom_point(aes(x=LONGITUD,y=LATITUDE)) + coord_map(project="mercator") + xlim(-130, -60) + ylim(20, 55)

b = map_data("state")

png("occupants_map.png", width=2000, height=2000, res=120)
map <- ggplot(accidents)
map = map + geom_point(aes(x=LONGITUD,y=LATITUDE,color=PERSONS), size=2.0)
map = map + coord_map(project="mercator") + xlim(-125, -115) + ylim(32, 45)
map = map + scale_color_gradient(limits=c(0, 4), low = "yellow", high = "blue")
map = map + geom_path(data=b, aes(x=long,y=lat,group=group), colour="black", alpha=0.5)
map
dev.off()

png("occupants_fatals_map_texas.png", width=2000, height=2000, res=120)
map <- ggplot(accidents)
map = map + geom_point(aes(x=LONGITUD,y=LATITUDE,size=FATALS,color=FATALS))
map = map + coord_map(project="mercator") + xlim(-107, -93) + ylim(26, 37)
map = map + scale_color_gradient(limits=c(0, 4), low = "yellow", high = "blue")
map = map + geom_path(data=b, aes(x=long,y=lat,group=group), colour="black", alpha=0.5)
map
dev.off()

hosp_arrival <- ggplot(data = (accidents))
hosp_arrival = hosp_arrival + geom_histogram(aes(x = HOSP_TRAVEL_TIME)) + xlim(1, 120)
hosp_arrival

png("hospital_travel_time.png", width=2000, height=2000, res=120)
map <- ggplot(accidents)
map = map + geom_point(aes(x=LONGITUD,y=LATITUDE,color=HOSP_TRAVEL_TIME), size=0.9)
map = map + coord_map(project="mercator") + xlim(-107, -93) + ylim(26, 37)
map = map + scale_color_gradient(limits=c(1, 120), low = "blue", high = "red")
map = map + geom_path(data=b, aes(x=long,y=lat,group=group), colour="black", alpha=0.5)
map
dev.off()

# Monthly correlation
ggplot(accidents, aes(x = MONTH)) + geom_histogram(binwidth=0.5)

# Time of day -- Need more lights
qplot(LGT_COND, data=accidents, geom="bar") + xlim("Day", "Dark-NL", "Dark-L", "Dawn", "Dusk", "Dark-?L", "Other", "?", "Unknown")

