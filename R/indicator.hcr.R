# 
# 
# 1. get initial catch advice from historical data / indicators / whatever
# 2. generate initial biomass vector and get opmod parameters
# 3. update operating model for Nt
# 4. gen new observations
# 5. get indicators
# 6. do assessment
# 7. get catch advice from hcr
# 8. goto 3, loop 3-7 until tstop
# 9. calculate performance measures
# 
# 
# mgmt options
# 1. random Frate
# 2. fix at single-species Fmsy from current assessment - no assessment error
# 3. fix at single-species Fmsy from current assessment - given observation error, no assessment error
# 4. fix at single-species Fmsy, assessment error (estimate Fmsy)
# 5. single-species Fmsy control rule, reduce F at low biomass, assessment error (estimate Fmsy)
# 6. random Frate, indicator control rules
# 7. single-species Fmsy, indicator control rule
# 8. single-species Fmsy, reduce F at low biomass, indicator control rule
# 9. single-species Fmsy, indicator-based ceiling on catch
# 10.single-species Fmsy, reduce F at low biomass, indicator-based ceiling on catch
# 
# performance measures
# Indicators
# Propstocks below 0.5*BMSY
# Propstocks that went below 0.5*BMSY >=10% of the time
# species richness....
# variability in totcat over time
# variability in species richness of catch over time
#' 


indicator.hcr <- function(refvals,limvals,use.defaults=TRUE,get.fmults=TRUE,indvals)
{
  reffile <- "indicator_refvals.csv"
  ind.hcr <- read.csv(reffile,header=TRUE)
  if (use.defaults==TRUE)
  {
    refvals <- ind.hcr[,3]
    limvals <- ind.hcr[,4]
    names(refvals) = ind.hcr[,1]
    names(limvals) = ind.hcr[,1]
  }
  if (get.fmults==TRUE)
  {
    fmult <- matrix(NA,nrow=length(refvals),ncol=10)
    for (ind.use in 1:length(refvals))
    {
      name = names(refvals[ind.use])
      i <- which(names(indvals)== name)
      #print(c(i,ind.use,refvals[ind.use],limvals[ind.use]))
      if (refvals[ind.use]>=limvals[ind.use] & ind.use !=5)
      {
        if (indvals[i]>=refvals[ind.use]) temp = 1
        if (indvals[i]<limvals[ind.use]) temp = 0
        if (indvals[i]<refvals[ind.use] && indvals[i]>=limvals[ind.use])
        {
          temp = (indvals[i]-limvals[ind.use])/(refvals[ind.use]-limvals[ind.use])
        }
        fmult[ind.use,] = -1*temp*as.numeric(ind.hcr[ind.use,6:15])
      }
      if (refvals[ind.use]<limvals[ind.use] | ind.use== 5)
      {
        if (indvals[i]<=refvals[ind.use]) temp = 1
        if (indvals[i]>limvals[ind.use]) temp = 0
        if (indvals[i]>refvals[ind.use] && indvals[i]<=limvals[ind.use])
        {
          temp = (indvals[i]-limvals[ind.use])/(refvals[ind.use]-limvals[ind.use])
        }
        fmult[ind.use,] = -1*temp*as.numeric(ind.hcr[ind.use,6:15])
      }
      #print(i)
      #print(fmult)
    }
    fmult[which(is.na(fmult)==TRUE)] = 1
    return(fmult)
  }
  if (get.fmults==FALSE)
  {
    bounds <- matrix(c(6,3,6,3,1,0,0,1,0,1,0,1,0,1,20,0),ncol=2,byrow=TRUE)
    rownames(bounds) = ind.hcr[,1]
    refvals <- rep(NA,nrow(bounds))
    limvals <- rep(NA,nrow(bounds))
    for (i in 1:nrow(bounds))
    {
      flag=0
      lo <- which.min(bounds[i,])
      hi <- which.max(bounds[i,])
      if (bounds[i,2]>bounds[i,1])
      {
        flag=1
      }
      if (i==3)
      {
        refvals[i] <- runif(1,bounds[i,2],bounds[i,1])
        limvals[i] <- runif(1,refvals[i],bounds[i,1])
      }
      if (i==4)
      {
        refvals[i] <- runif(1,bounds[i,1],refvals[i-1])
        limvals[i] <- runif(1,bounds[i,1],refvals[i])
      }
      if (i==5)
      {
        refvals[i] <- runif(1,bounds[i,1],bounds[i,2])
        limvals[i] <- refvals[i]
      }
      if (i==6)
      {
        refvals[i] <- runif(1,bounds[i,lo],refvals[i-1])
        limvals[i] <- refvals[i]
      }
      vec <- c(1,2,7,8)
      if (is.na(match(i,vec))==FALSE)
      {
        refvals[i] <- runif(1,bounds[i,lo],bounds[i,hi])
        if (flag==0) limvals[i] <- runif(1,bounds[i,lo],refvals[i])
        if (flag==1) limvals[i] <- runif(1,refvals[i],bounds[i,hi])
      }
    }
    names(refvals) = ind.hcr[,1]
    names(limvals) = ind.hcr[,1]
    refpts <- NULL
    refpts$refvals <- refvals
    refpts$limvals <- limvals
    return(refpts)
  }
  
}

#xx <- indicator.hcr(refvals,limvals,use.defaults=TRUE,get.fmults=TRUE,indvals=indvals)
#xx <- indicator.hcr(xx$refvals,xx$limvals,use.defaults=FALSE,get.fmults=TRUE,indvals=indvals)


