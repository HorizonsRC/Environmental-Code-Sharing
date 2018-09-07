# Example code

#####################################################################################
#
#  Task Name:       <- Calculation of Rating curve envelope from one cross section 
#
#  Task Purpose:    <- Calculation of a range of flow (depending on a Monte Carlo analysis on a range of manning) 
#                   <- for each level h on a specified cross section, using manning's formula.
#
#  Task Outputs:    <- Return a table containing results
#                   <- Output : two png plots, check output filepath on lanes 47 and 148.
#
#  Notes:           <- Need to import cross section data on the shape x/y, with x in meters and y in milimeters please check the import path name
#
#  Created by:      <- N.Poncet
#  Created on:      <- 14/05/2018
#
#  Last updated:    <- 07/09/2018
#  Last updated by: <- R Dev Group
#
####################################################################################

# Various Plotting Functions Library
library(plotrix)

#Loading function 
source("Function_CrossSectionAnalysis.R")


#----------------------Import variables------------------------------

filepath = "UpperGorge.txt" # load in cross section
R= 0.1 
Slope=0.001

#Monte Carlo parameters for manning parameter
n_min=0.025
n_max=0.045
runs=1000

namesite = "Upper Gorge"
output_png = "Outputs/ManningRating_"

#---------------------------Data preparation------------------------

# Create png that plots will be saved to
png(filename =paste(output_png,namesite,".png",sep = ""),
    width = 20,
    height = 20,
    units = "cm",
    pointsize = 8,
    res = 600,
    bg = "white",
    family = "sans")

#Creation of the random mannings table
n = runif(runs,n_min,n_max)


par(mfrow=c(2,2),
    mar=c(5,5,3,3),
    oma = c(0,0,4,0))

# Calculate Manning parameters
CSAnalysis = CS.WetArea(filepath,R)
CSAnalysis$WetPerimeter = CS.WetPerimeter(filepath,R)[,2]
CSAnalysis$RadiusHyd = CSAnalysis$WetArea/CSAnalysis$WetPerimeter
CSAnalysis[1,4]=0

# Creating an empty data frame for results to be added
Results=data.frame()

#------------------------Flow range Calculation-------------------------

for(i in 1:nrow(CSAnalysis)) {
  
  Q = CSAnalysis$WetArea[i]*(1/n)*(CSAnalysis$RadiusHyd[i] ^ (2/3)) * (Slope ^ (1/2))   # Calculate flow
  Results = rbind(Results,summary(Q))   # Add flow into results frame
  Results[i,7]=sd(Q)
  
}

colnames(Results)=c(names(summary(Q)),'sd')
Results = cbind(Results, h = CSAnalysis$h)

View(Results)

#Creation of a light results table for summary plot table

Results_light = signif(Results[ceiling(seq(from = 0,to = 1,by = 0.1)*nrow(CSAnalysis)),],4)
row.names(Results_light)=Results_light$h



#---------------------------Main plots---------------------------

plot(CSAnalysis$h,CSAnalysis$WetArea,
     xlab = "h (m)",ylab= "Wet Area (m)",main = "Wet Area in function of water level",
     type = 'l',
     lwd=1.75,
     panel.first = grid(col = "grey",equilogs = TRUE))

plot(CSAnalysis$h,CSAnalysis$WetPerimeter,
     xlab = "h (m)",ylab= "Wet Perimeter (m)",main = "Wet Perimeter in function of water level",
     type = 'l',
     lwd=1.75,
     panel.first = grid(col = "grey",equilogs = TRUE))

plot(Results$Mean,Results$h,
     xlab = "Discharge (m3/s)",ylab= "h (m)",main = "Rating Curve",
     type = 'l',
     lwd=2,
     col = 'darkblue',
     panel.first = grid(col = "grey",equilogs = TRUE))
lines(Results$`1st Qu.`,Results$h,
      lty = 2,
      col = 'blue')
lines(Results$`3rd Qu.`,Results$h,
      lty = 2,
      col = 'blue')
lines(Results$Min.,Results$h,
      lty = 3,
      col = 'blue')
lines(Results$Max.,Results$h,
      lty = 3,
      col = 'blue')


legend("bottomright",
       legend = c("Minimum and Maximum values","1st and 3rd Quantiles","Mean") ,
       col=c("blue","blue","darkblue"), 
       text.font=1,
       lty=c(3,2,1),
       bg="skyblue")

title(paste("Rating establishment for one cross section using Manning's equation at ",namesite,sep = ''),
      outer = TRUE,
      cex = 1.5)

dev.off()


#-------------------------------Secondary Plot with Summary table----------------------------------------

png(filename =paste(output_png,namesite,"_Summary.png",sep = ""),
    width = 15,
    height = 20,
    units = "cm",
    pointsize = 8,
    res = 600,
    bg = "white",
    family = "sans")

par(mar = c(4,4,4,4),font = 2,oma=c(2,2,5,2))
layout(cbind(c(1,2,2,2),c(1,2,2,2)))


plot.new()

addtable2plot(-0.02,-0.25,Results_light,lwd = 1,cex = 1.2,bty = 'o',hlines = TRUE,vlines = TRUE,xpad = 0.5,ypad = 1)

plot(Results$Max.,Results$h,
     xlab = "Discharge (m3/s)",ylab= "h (m)", main = "Rating Curve",
     cex.main = 1.5,
     type = 'l',
     lty = 3,
     col = 'blue',
     panel.first = grid(col = "grey",equilogs = TRUE),
     font.lab = 2)

lines(Results$`1st Qu.`,Results$h,
      lty = 2,
      col = 'blue')
lines(Results$`3rd Qu.`,Results$h,
      lty = 2,
      col = 'blue')
lines(Results$Min.,Results$h,
      lty = 3,
      col = 'blue')
lines(Results$Mean,Results$h,
      lty = 1,
      lwd = 3,
      col = 'darkblue')

legend("bottomright",
       legend = c("Minimum and Maximum values","1st and 3rd Quantiles","Mean") ,
       col=c("blue","blue","darkblue"), 
       text.font=1,
       lty=c(3,2,1),
       bg="skyblue",
       cex = 1.5)


title(paste("Rating curve for one cross section using Manning's equation","\nat",namesite),
      cex.main = 1.9, outer = TRUE,line = -0.5)

dev.off()



