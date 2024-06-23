---
title: "Reconstitution Code"
author: "Marshall"
date: "2024-06-12"
output: html_document
---


``` r
knitr::opts_chunk$set(echo = TRUE)
library(tidyverse)
library(knitr)
library(readxl)# For importing from excel spreadsheets
library(visNetwork)#networking interactive graph package
library(lubridate)
```

## R Markdown




## Including Plots

You can also embed plots, for example:


``` r
raw_data<-raw_data%>%
  mutate(Effective=if_else(is.na(Effective), as.Date("1995/04/01"), Effective),
         RV=if_else(is.na(RV), 0, RV))#cleaning the data on RV and dates here so it is easier to do

raw_data<-raw_data%>%
  mutate(str_replace_all(Effective,"-","/"))#formatting the dates to be better

colnames(raw_data)<-c("Assessments","Address","RV","Effective","Alteration","Change Reason","Notes","List","AK","Case","Assessment","Relationship","effective_date")

new_nodes<-raw_data%>%
  select(AK,effective_date,RV)#creating the nodes list

new_nodes<-new_nodes%>%
  group_by(AK)%>%
  slice(which.max(as_date(effective_date)))#selecting the RV based on the most recent entry for each AK

nodes<-new_nodes%>%
  ungroup()%>%
  mutate(group=if_else(RV>0&RV<12000,"full sbr",
                                 if_else(RV>=12000&RV<15000,"partial sbr",
                                         if_else(RV==0,"zero","inelligible"))))#labelling each AK with whether it is elligible for SBRR for the colouring of the nodes

names(nodes)[names(nodes)=="AK"]<-"id"#renaming the column for the network to read AK as the id

cases<-raw_data%>%
  group_by(Case)%>%
  group_by(Relationship)#creating a new data set that is grouped for checking purposes

cases$from<-0#creating the from column for the edge data

cases$to<-0#creating the to column for the edge data

cases <- cases%>%
  mutate(to=ifelse(Relationship=="Child",
                   cases$AK, cases$to))#for child cases putting the AK in the to column

cases <- cases%>%
  mutate(from=ifelse(Relationship=="Parent"
                     ,cases$AK, cases$from))#for parent cases putting the AK in the from column

parent_values <- cases%>%
  filter(Relationship=="Parent")%>%
  select(AK,Case,Relationship)#creating the parent data

child_values <- cases%>%
  filter(Relationship=="Child")%>%
  select(AK,Case,Relationship)#creating the child data

final_cases_parent<-left_join(cases,parent_values,by="Case")#binds the parent data to the cases dataset
```

```
## Warning in left_join(cases, parent_values, by = "Case"): Detected an unexpected many-to-many relationship between `x` and `y`.
## ℹ Row 5 of `x` matches multiple rows in `y`.
## ℹ Row 1 of `y` matches multiple rows in `x`.
## ℹ If a many-to-many relationship is expected, set `relationship = "many-to-many"` to silence this warning.
```

``` r
final_cases_child<-left_join(cases,child_values,by="Case")#binds the child data to the cases dataset
```

```
## Warning in left_join(cases, child_values, by = "Case"): Detected an unexpected many-to-many relationship between `x` and `y`.
## ℹ Row 5 of `x` matches multiple rows in `y`.
## ℹ Row 1 of `y` matches multiple rows in `x`.
## ℹ If a many-to-many relationship is expected, set `relationship = "many-to-many"` to silence this warning.
```

``` r
final_cases_together<-rbind(final_cases_child,final_cases_parent)#binds the 2 datasets together

final_cases<-as.data.frame(c("from","to"))#creating a dateset to input the new code into

names(final_cases_together)[names(final_cases_together) == 'Relationship.x'] <- 'Relationship'#renaming column for matching purposes

final_cases<-final_cases_together%>%
  filter(Relationship!=is.na(final_cases_together$Relationship))%>%
  mutate(to=ifelse(Relationship=="Parent" & Relationship.y=="Child"&from!=0&to==0,
                   AK.y,to))#creating the matching algorithm for cases to create the from and to column

address_change_data <- raw_data%>%
  filter(`Change Reason`=="ADDRESS CHANGE & REVIEW OF ASSESSMENT")#creating the dataset for address changes

address_change_data<-address_change_data%>%
  mutate(from=if_else(RV==0,AK,0),
         to=if_else(RV!=0,AK,0))#matching the dataset to create the columns

address_from_data<-address_change_data%>%
  sort_by(address_change_data$Case)%>%
  filter(from!=0)#ordering the data so that the resulting dataframe matches correctly and then filtering out the irrelevant data for one half of the dataset

address_to_data<-address_change_data%>%
  sort_by(address_change_data$Case)%>%
  filter(to!=0)#ordering the data so that the resulting dataframe matches correctly and then filtering out the irrelevant data for one half of the dataset

address_link_data<-data.frame(address_from_data$from,address_to_data$to)#creating this dataset

colnames(address_link_data)<-c("from","to")#renaming the columns to match the reconstitutions dataset

address_link_data<-address_link_data%>%
  distinct()#removing any duplicates

address_link_data<-address_link_data%>%
  mutate(color="purple")#adding this column so the edges colour correctly in the graph
```




``` r
link_data<-data.frame(final_cases$from,final_cases$to)#the reconstitution dataframe

colnames(link_data)<-c("from","to")#renaming column to be recognised by visnetwork

link_data<-link_data%>%
  filter(from!=0)%>%
  filter(to!=0)#removing any values that are 0

link_data<-link_data%>%
  mutate(color="pink")#adding this to add the colour of the node

link_data<-link_data%>%
  distinct()#removing any duplicates

link_data_all<-rbind(link_data,address_link_data)#joining the 2 sets of edge data together

ledges<-data.frame(color=c("pink","purple"),
                   label=c("Reconstitution","ADDRESS CHANGE & REVIEW OF ASSESSMENT"),
                   width=5)#label for the graph

network_graph<-visNetwork(nodes,link_data_all,physics=FALSE,width="100%")%>%
  visNodes()%>%
  visEdges(arrows = "middle",width = 5)%>%
  visGroups(groupname = "zero", color="lightblue")%>%
  visGroups(groupname = "full sbr", color="lightgreen")%>%
  visGroups(groupname = "partial sbr", color="orange")%>%
  visGroups(groupname = "inelligible", color="red")%>%
  visOptions(nodesIdSelection = TRUE,highlightNearest = TRUE,selectedBy = "group")%>%
  visLegend(addEdges = ledges,
            addNodes=list(font.color = "white"))

visSave(network_graph,"Interactive graph.html")#saves the graph
```

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
